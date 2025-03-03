# 
# Minimal GUI for PCGLNS
# 
using namespace System.Windows.Forms

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    x:Name="Window"
    Title="Run PGCLNS"
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
    <TextBlock Text="Режим" />
    <ComboBox x:Name="mode" SelectedIndex="1" Padding="5 1" Margin="0 0 0 5">
        <ComboBoxItem>Fast</ComboBoxItem>
        <ComboBoxItem>Default</ComboBoxItem>
        <ComboBoxItem>Slow</ComboBoxItem>
    </ComboBox>
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
 

$btnSrc.add_click({ browsePcglns })
$btnDst.add_click({ browseTxt })
$btnGo.add_click({ Run })

function browsePcglns {
    $d = New-Object OpenFileDialog
    $d.Title = "Выберите файл с моделью PCGLNS для решения"
    $d.Filter = 'Модели PCGLNS|*.pcglns|Все файлы|*.*'
  
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
    $window.DialogResult = $true    
}

browsePcglns
if (!$src.Text) {
    exit
}

if (!$window.ShowDialog()) {
    exit
}

$argz = @(
    Join-Path (Split-Path $PSCommandPath -Parent) runPCGLNS.jl
    $src.Text
    "-mode=$($mode.Text.ToLower())"
)
if ($dst.Text) {
    $argz += @("-output=" + $dst.Text)
}

julia @argz

Write-Output "Нажмите любую клавищу для завершения..."
[Console]::ReadKey(1) | Out-Null
