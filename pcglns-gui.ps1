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

$window.ShowDialog()