using Microsoft.Maui.Layouts;
using Microsoft.Maui.Primitives;
using Xunit;


namespace Microsoft.Maui.UnitTests.Layouts
{
	[Category(TestCategory.Core, TestCategory.Layout)]
	public class ConstraintTests
	{
		[Theory("When resolving constraints, external constraints take precedence")]
		[InlineData(100, 200, 130, 100)]
		[InlineData(100, Dimension.Unset, 130, 100)]
		public void ExternalWinsOverDesiredAndMeasured(double externalConstraint, double explicitLength, double measured, double expected)
		{
			var resolution = LayoutManager.ResolveConstraints(externalConstraint, explicitLength, measured);
			Assert.Equal(expected, resolution);
		}

		[Fact("If external and request constraints don't apply, constrain to measured value")]
		public void MeasuredWinsIfNothingElseApplies()
		{
			var resolution = LayoutManager.ResolveConstraints(double.PositiveInfinity, Dimension.Unset, 245);
			Assert.Equal(245, resolution);
		}

		[Fact("If external constraints don't apply, constrain to requested value")]
		public void RequestedTakesPrecedenceOverMeasured()
		{
			var resolution = LayoutManager.ResolveConstraints(double.PositiveInfinity, 90, 245);
			Assert.Equal(90, resolution);
		}
	}
}
