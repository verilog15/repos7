using System;
using Microsoft.Maui.Controls.Core.UnitTests;
using NUnit.Framework;

namespace Microsoft.Maui.Controls.Xaml.UnitTests
{
	public partial class SetStyleIdFromXName : ContentPage
	{
		public SetStyleIdFromXName() => InitializeComponent();
		public SetStyleIdFromXName(bool useCompiledXaml)
		{
			//this stub will be replaced at compile time
		}

		[TestFixture]
		public class Tests
		{
			[TestCase(false), TestCase(true)]
			public void SetStyleId(bool useCompiledXaml)
			{
				var layout = new SetStyleIdFromXName(useCompiledXaml);
				Assert.That(layout.label0.StyleId, Is.EqualTo("label0"));
				Assert.That(layout.label1.StyleId, Is.EqualTo("foo"));
				Assert.That(layout.label2.StyleId, Is.EqualTo("bar"));
			}
		}
	}
}
