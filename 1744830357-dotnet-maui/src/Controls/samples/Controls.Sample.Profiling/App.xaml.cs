﻿using Microsoft.Maui;
using Microsoft.Maui.Controls;

namespace Maui.Controls.Sample.Profiling
{
	public partial class App : Application
	{
		public App()
		{
			InitializeComponent();
		}

		protected override Window CreateWindow(IActivationState activationState)
		{
			return new Window(new MainPage());
		}
	}
}