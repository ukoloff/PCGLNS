# Copyright 2017 Stephen L. Smith and Frank Imeson
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
module PCGLNS
export solver

using Random

include("utilities.jl")
include("parse_print.jl")
include("tour_optimizations.jl")
include("adaptive_powers.jl")
include("insertion_deletion.jl")
include("parameter_defaults.jl")

const global EPS = 1.0e9

"""
Main GTSP solver, which takes as input a problem instance and
some optional arguments.
"""
function solver(problem_instance; args...)

    # Read problem data and solver settings.
    num_vertices, num_sets, sets, set_orderings, dist, membership, start_set =
        read_file(problem_instance)
    param = parameter_settings(num_vertices, num_sets, sets, problem_instance, args)

    order_constraints = calc_order_constraints(sets, set_orderings)

    init_time = time()
    count = Dict(
        :latest_improvement => 1,
        :first_improvement => false,
        :warm_trial => 0,
        :cold_trial => 1,
        :total_iter => 0,
        :print_time => init_time,
    )
    lowest = Tour(Int64[], typemax(Int64))
    start_time = time_ns()

    # Compute set distances which will be helpful.
    setdist = set_vertex_dist(dist, num_sets, membership)
    powers = initialize_powers(param)

    while count[:cold_trial] <= param[:cold_trials]

        # Build tour from scratch on a cold restart.
        best = initial_tour!(
            lowest,
            dist,
            sets,
            order_constraints,
            setdist,
            count[:cold_trial],
            membership,
            param,
            start_set,
        )

        # Print_cold_trial(count, param, best).
        phase = :early

        if count[:cold_trial] == 1
            powers = initialize_powers(param)
        else
            power_update!(powers, param)
        end

        while count[:warm_trial] <= param[:warm_trials]
            iter_count = 1
            current = Tour(copy(best.tour), best.cost)
            temperature = 1.442 * param[:accept_percentage] * best.cost

            # Accept a solution with 50% higher cost with 0.05% change after num_iterations.
            cooling_rate =
                (
                    (0.0005 * lowest.cost) / (param[:accept_percentage] * current.cost)
                )^(1 / param[:num_iterations])

            # If warm restart, then use lower temperature.
            if count[:warm_trial] > 0
                temperature *= cooling_rate^(param[:num_iterations] / 2)
                phase = :late
            end

            while count[:latest_improvement] <= (
                count[:first_improvement] ? param[:latest_improvement] :
                param[:first_improvement]
            )
                # Move to mid phase after half iterations.
                if iter_count > param[:num_iterations] / 2 && phase == :early
                    phase = :mid
                end
                trial = remove_insert(
                    current,
                    best,
                    dist,
                    membership,
                    setdist,
                    sets,
                    order_constraints,
                    powers,
                    param,
                    phase,
                    start_set,
                )

                # Decide whether or not to accept trial.
                if accepttrial_noparam(trial.cost, current.cost, param[:prob_accept]) ||
                   accepttrial(trial.cost, current.cost, temperature)
                    param[:mode] == "slow" && opt_cycle!(
                        current,
                        dist,
                        sets,
                        order_constraints,
                        membership,
                        param,
                        setdist,
                        "full",
                        start_set,
                    )
                    current = trial
                end
                if current.cost < best.cost
                    count[:latest_improvement] = 1
                    count[:first_improvement] = true
                    if count[:cold_trial] > 1 && count[:warm_trial] > 1
                        count[:warm_trial] = 1
                    end
                    opt_cycle!(
                        current,
                        dist,
                        sets,
                        order_constraints,
                        membership,
                        param,
                        setdist,
                        "full",
                        start_set,
                    )
                    best = current
                else
                    count[:latest_improvement] += 1
                end

                # If we've come in under budget, or we're out of time, then exit.
                if best.cost <= param[:budget] || time() - init_time > param[:max_time]
                    param[:timeout] = (time() - init_time > param[:max_time])
                    param[:budget_met] = (best.cost <= param[:budget])
                    timer = (time_ns() - start_time) / EPS
                    lowest.cost > best.cost && (lowest = best)
                    print_best(count, param, best, lowest, init_time)
                    print_summary(lowest, timer, membership, param)
                    return
                end

                # Cool the temperature.
                temperature *= cooling_rate
                iter_count += 1
                count[:total_iter] += 1
                print_best(count, param, best, lowest, init_time)
            end

            # On the first cold trial, we are just determining.
            print_warm_trial(count, param, best, iter_count)
            count[:warm_trial] += 1
            count[:latest_improvement] = 1
            count[:first_improvement] = false
        end

        lowest.cost > best.cost && (lowest = best)
        count[:warm_trial] = 0
        count[:cold_trial] += 1
    end

    timer = (time_ns() - start_time) / EPS
    print_summary(lowest, timer, membership, param)
end
end
