using System;
using System.Collections.Generic;
using Microsoft.Maui.Controls;
using Microsoft.Maui.Controls.Core.UnitTests;
using NUnit.Framework;

namespace Microsoft.Maui.Controls.Xaml.UnitTests
{
	public partial class Gh5705 : Shell
	{
		public Gh5705() => InitializeComponent();
		public Gh5705(bool useCompiledXaml)
		{
			//this stub will be replaced at compile time
		}

		[TestFixture]
		class Tests
		{

			[Test]
			public void SearchHandlerIneritBC([Values(false, true)] bool useCompiledXaml)
			{
				var vm = new object();
				var shell = new Gh5705(useCompiledXaml) { BindingContext = vm };
				Assert.That(shell.searchHandler.BindingContext, Is.EqualTo(vm));
			}
		}
	}
}
