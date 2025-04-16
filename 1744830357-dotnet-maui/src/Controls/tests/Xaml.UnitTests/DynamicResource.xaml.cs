using System;
using System.Collections.Generic;
using Microsoft.Maui.Controls;
using Microsoft.Maui.Controls.Core.UnitTests;
using NUnit.Framework;

namespace Microsoft.Maui.Controls.Xaml.UnitTests
{
	public partial class DynamicResource : ContentPage
	{
		public DynamicResource()
		{
			InitializeComponent();
		}

		public DynamicResource(bool useCompiledXaml)
		{
			//this stub will be replaced at compile time
		}

		[TestFixture]
		public class Tests
		{
			[TestCase(false), TestCase(true)]
			public void TestDynamicResources(bool useCompiledXaml)
			{
				var layout = new DynamicResource(useCompiledXaml);
				var label = layout.label0;

				Assert.Null(label.Text);

				layout.Resources = new ResourceDictionary {
					{"FooBar", "FOOBAR"},
				};
				Assert.AreEqual("FOOBAR", label.Text);
			}
		}
	}
}