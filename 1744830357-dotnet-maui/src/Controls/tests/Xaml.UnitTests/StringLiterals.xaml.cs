using System;
using System.Collections.Generic;
using Microsoft.Maui.Controls;
using Microsoft.Maui.Controls.Core.UnitTests;
using NUnit.Framework;

namespace Microsoft.Maui.Controls.Xaml.UnitTests
{
	public partial class StringLiterals : ContentPage
	{
		public StringLiterals()
		{
			InitializeComponent();
		}

		public StringLiterals(bool useCompiledXaml)
		{
			//this stub will be replaced at compile time
		}

		[TestFixture]
		public class Tests
		{
			[TestCase(false)]
			[TestCase(true)]
			public void EscapedStringsAreTreatedAsLiterals(bool useCompiledXaml)
			{
				var layout = new StringLiterals(useCompiledXaml);
				Assert.AreEqual("Foo", layout.label0.Text);
				Assert.AreEqual("{Foo}", layout.label1.Text);
				Assert.AreEqual("Foo", layout.label2.Text);
				Assert.AreEqual("Foo", layout.label3.Text);
			}
		}
	}
}