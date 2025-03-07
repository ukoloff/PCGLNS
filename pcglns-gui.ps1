# 
# Minimal GUI for PCGLNS
# 
using namespace System.Windows.Forms

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

$URL = 'https://ukoloff.github.io/j2pcgtsp/'

[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window"
    Title="Запуск эвристики PGCLNS"
    Height="200" MinWidth="500"
    WindowStartupLocation="CenterScreen"
    SizeToContent="WidthAndHeight"
>
<StackPanel Margin="5">
    <TextBlock Text="Модель для решения" />
    <Grid>
        <Grid.ColumnDefinitions>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="Auto" />
        </Grid.ColumnDefinitions>
        <TextBox x:Name="src" MaxLength="50"  />
        <Button x:Name="btnSrc" Grid.Column="1" Content="Обзор" Padding="5 0" />
    </Grid>
    <TextBlock Text="Результат" />
    <Grid>
        <Grid.ColumnDefinitions>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="Auto" />
        </Grid.ColumnDefinitions>
        <TextBox x:Name="dst" MaxLength="50"  />
        <Button x:Name="btnDst" Grid.Column="1" Content="Обзор" Padding="5 0" />
    </Grid>
    <CheckBox x:Name="overwrite" Content="Перезаписать, не задавая вопросов" />
    <TextBlock Text="Режим" />
    <ComboBox x:Name="mode" SelectedIndex="1" Padding="5 1" Margin="0 0 0 5">
        <ComboBoxItem>Fast</ComboBoxItem>
        <ComboBoxItem>Default</ComboBoxItem>
        <ComboBoxItem>Slow</ComboBoxItem>
    </ComboBox>
    <CheckBox x:Name="svg" IsChecked="True" Content="По окончании открыть страницу визуализации" />
    <Separator />
    <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" >
        <Button Content="Go!" x:Name="btnGo" IsDefault="True" Padding="9 0"/>
        <Button Content="Закрыть" IsCancel="True" Padding="9 0" Margin="7 0"/>
    </StackPanel>
</StackPanel>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# https://blog.it-kb.ru/2014/10/10/wpf-forms-for-powershell-scripts/
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | % {
    Set-Variable -Name ($_.Name) -Value $window.FindName($_.Name) -Scope Global
}
 
$window.Add_ContentRendered({ browsePcglns })
$btnSrc.add_click({ browsePcglns })
$btnDst.add_click({ browseTxt })
$btnGo.add_click({ Run })

function browsePcglns {
    $d = New-Object OpenFileDialog
    $d.Title = "Выберите файл с моделью PCGLNS для решения"
    $d.Filter = 'Модели PCG(TSP/LNS)|*.pcgtsp;*.pcglns|Модели PCGLNS|*.pcglns|Модели PCGTSP|*.pcgtsp|Все файлы|*.*'
  
    if ($d.ShowDialog() -ne "OK") {
        return
    }
    $src.Text = $d.FileName
    $dst.Text = [System.IO.Path]::ChangeExtension($d.FileName, '.result.txt')
}

function browseTxt {
    $d = New-Object OpenFileDialog
    $d.Title = "Выберите файл для сохранения результатов расчёта"
    $d.Filter = 'Результаты счёта|*.result.txt|Все файлы|*.*'
    $d.ValidateNames = 0
    $d.CheckFileExists = 0
    $d.CheckPathExists = 1

    $p = $dst.Text 
    if (!$p) {
        $p = $src.Text
    }
    if ($p) {
        $d.InitialDirectory = Split-Path $p -Parent
        $d.FileName = Split-Path $p -Leaf
    }
  
    if ($d.ShowDialog() -ne "OK") {
        return
    }
    $dst.Text = $d.FileName
}

function Run {
    if (!$src.Text -or !(Test-Path $src.Text -PathType Leaf)) {
        browsePcglns
        return
    }
    if ($dst.Text -and !$overwrite.IsChecked -and (Test-Path $dst.Text -PathType Leaf)) {
        $res = $dst.Text
        $res = [Messagebox]::Show("Перезаписать файл <$res>?", "PCGLNS",
            [MessageBoxButtons]::YesNo,
            [MessageBoxIcon]::Hand
        )
        if ($res -ne "Yes") { return }
    }
    $window.DialogResult = $true    
}

if (!$window.ShowDialog()) {
    exit
}

$pcglns = $src.Text
if ($pcglns -match "[.]pcgtsp$") {
    "Generating PCGLNS from <$pcglns>..."
    $cd = Get-Location
    Set-Location (Split-Path $pcglns -Parent)
    $pcglns = Split-Path $pcglns -Leaf
    $argz = @(
        Join-Path (Split-Path $PSCommandPath -Parent) convertToPCGLNS.py
        $pcglns 
        $env:TEMP        
    )
    python @argz 
    Set-Location $cd
    $pcglns = [System.IO.Path]::ChangeExtension($pcglns, '.pcglns')
    $pcglns = Join-Path $env:TEMP $pcglns
}

$argz = @(
    Join-Path (Split-Path $PSCommandPath -Parent) runPCGLNS.jl
    $pcglns
    "-mode=$($mode.Text.ToLower())"
)
if ($dst.Text) {
    $argz += @("-output=" + $dst.Text)
}

"Запускаем эвристику PCGLNS..."

julia @argz

Write-Output @"

Просмотр результатов доступен по адресу: $URL

Нажмите любую клавищу для завершения...
"@

if ($svg.IsChecked) { 
    Start-Process $URL 
}

[Console]::ReadKey(1) | Out-Null
