using System;
using System.Collections.Generic;
using Microsoft.Maui.Controls;
using Microsoft.Maui.Controls.Core.UnitTests;
using NUnit.Framework;

namespace Microsoft.Maui.Controls.Xaml.UnitTests
{
	public partial class Gh6648 : ContentPage
	{
		public Gh6648() => InitializeComponent();
		public Gh6648(bool useCompiledXaml)
		{
			//this stub will be replaced at compile time
		}

		[TestFixture]
		class Tests
		{
			[Test]
			public void DoesntFailOnNullDataType([Values(true)] bool useCompiledXaml)
			{
				if (useCompiledXaml)
					Assert.DoesNotThrow(() => MockCompiler.Compile(typeof(Gh6648)));
			}

			[Test]
			public void BindingsOnxNullDataTypeWorks([Values(true, false)] bool useCompiledXaml)
			{
				var layout = new Gh6648(useCompiledXaml);
				layout.stack.BindingContext = new { foo = "Foo" };
				Assert.That(layout.label.Text, Is.EqualTo("Foo"));
			}
		}
	}
}
