using System;
using Microsoft.Maui.Controls.Core.UnitTests;
using NUnit.Framework;

namespace Microsoft.Maui.Controls.Xaml.UnitTests
{
	public partial class BuiltInConversions : ContentPage
	{
		public BuiltInConversions()
		{
			InitializeComponent();
		}

		public BuiltInConversions(bool useCompiledXaml)
		{
			//this stub will be replaced at compile time
		}

		[TestFixture]
		public class Tests
		{
			[TestCase(false)]
			[TestCase(true)]
			public void Datetime(bool useCompiledXaml)
			{
				var layout = new BuiltInConversions(useCompiledXaml);

				Assert.AreEqual(new DateTime(2015, 01, 16), layout.datetime0.Date);
				Assert.AreEqual(new DateTime(2015, 01, 16), layout.datetime1.Date);
			}

			[TestCase(false)]
			[TestCase(true)]
			public void String(bool useCompiledXaml)
			{
				var layout = new BuiltInConversions(useCompiledXaml);

				Assert.AreEqual("foobar", layout.label0.Text);
				Assert.AreEqual("foobar", layout.label1.Text);

				//Issue #2122, implicit content property not trimmed
				Assert.AreEqual("foobar", layout.label2.Text);
			}
		}
	}
}