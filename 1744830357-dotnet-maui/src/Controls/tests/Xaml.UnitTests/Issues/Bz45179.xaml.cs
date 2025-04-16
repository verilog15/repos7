using System;
using System.Collections.Generic;
using Microsoft.Maui.Controls;
using Microsoft.Maui.Controls.Core.UnitTests;
using NUnit.Framework;

namespace Microsoft.Maui.Controls.Xaml.UnitTests
{
	public class Bz45179_0 : ContentView
	{
		public static int creator_count;
		public Bz45179_0()
		{
			creator_count++;
		}

	}
	public partial class Bz45179 : ContentPage
	{
		public Bz45179()
		{
			InitializeComponent();
		}

		public Bz45179(bool useCompiledXaml)
		{
			//this stub will be replaced at compile time
		}

		[TestFixture]
		class Tests
		{
			[TestCase(true)]
			[TestCase(false)]
			public void DTDoNotInstantiateTheirContent(bool useCompiledXaml)
			{
				Bz45179_0.creator_count = 0;
				Assume.That(Bz45179_0.creator_count, Is.EqualTo(0));
				var page = new Bz45179(useCompiledXaml);
				Assert.That(Bz45179_0.creator_count, Is.EqualTo(0));
			}
		}
	}
}