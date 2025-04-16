﻿namespace Microsoft.Maui.Handlers.Benchmarks
{
	interface IFooService
	{
	}

	interface IBarService
	{
	}

	interface IFooBarService
	{
	}

	class FooService : IFooService
	{
	}

	class BarService : IBarService
	{
	}

	class FooBarWithFooService : IFooBarService
	{
		public FooBarWithFooService(IFooService foo)
		{
			Foo = foo;
		}

		public IFooService Foo { get; }
	}

	class FooBarWithFooAndBarService : IFooBarService
	{
		public FooBarWithFooAndBarService(IFooService foo, IBarService bar)
		{
			Foo = foo;
			Bar = bar;
		}

		public IFooService Foo { get; }

		public IBarService Bar { get; }
	}

	class FooDualConstructor : IFooBarService
	{
		public FooDualConstructor(IFooService foo)
		{
			Foo = foo;
		}

		public FooDualConstructor(IBarService bar)
		{
			Bar = bar;
		}

		public IFooService Foo { get; }

		public IBarService Bar { get; }
	}

	class FooDefaultValueConstructor : IFooBarService
	{
		public FooDefaultValueConstructor(IBarService bar = null)
		{
			Bar = bar;
		}

		public IBarService Bar { get; }
	}

	class FooDefaultSystemValueConstructor : IFooBarService
	{
		public FooDefaultSystemValueConstructor(string text = "Default Value")
		{
			Text = text;
		}

		public string Text { get; }
	}
}