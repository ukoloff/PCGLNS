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
  <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" >
    <Button Content="Go!" x:Name="btnGo" IsDefault="True" Padding="9 0"/>
    <Button Content="Закрыть" IsCancel="True" Padding="9 0" Margin="7 0"/>
  </StackPanel>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$window.ShowDialog()