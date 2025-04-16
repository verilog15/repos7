﻿#nullable disable
using Microsoft.Maui.Graphics;
using Microsoft.Maui.Layouts;

namespace Microsoft.Maui.Controls
{
	public class AndExpandLayoutManager : ILayoutManager
	{
		IGridLayout _gridLayout;
		readonly StackLayout _stackLayout;
		GridLayoutManager _manager;

		public AndExpandLayoutManager(StackLayout stackLayout)
		{
			_stackLayout = stackLayout;
		}

		public Size Measure(double widthConstraint, double heightConstraint)
		{
			// We have to rebuild this every time because the StackLayout contents
			// and values may have changed
			_gridLayout?.Clear();
			_gridLayout = Gridify(_stackLayout);
			_manager = new GridLayoutManager(_gridLayout);

			return _manager.Measure(widthConstraint, heightConstraint);
		}

		public Size ArrangeChildren(Rect bounds)
		{
			if (_manager == null)
			{
				// This shouldn't really happen, but some compatibility layouts might be 
				// forcing a layout without a measure, so we'll have to ensure measurement happens here
				Measure(bounds.Width, bounds.Height);
			}

			return _manager.ArrangeChildren(bounds);
		}

		static IGridLayout Gridify(StackLayout stackLayout)
		{
			if (stackLayout.Orientation == StackOrientation.Vertical)
			{
				return AndExpandLayoutManager.ConvertToRows(stackLayout);
			}

			return AndExpandLayoutManager.ConvertToColumns(stackLayout);
		}

		static IGridLayout ConvertToRows(StackLayout stackLayout)
		{
			Grid grid = new AndExpandGrid(stackLayout)
			{
				ColumnDefinitions = new ColumnDefinitionCollection { new ColumnDefinition { Width = GridLength.Star } },
				RowDefinitions = new RowDefinitionCollection(),
				RowSpacing = stackLayout.Spacing,
			};

			var row = 0;
			for (int n = 0; n < stackLayout.Count; n++)
			{
				var child = stackLayout[n];

				if (child.Visibility != Visibility.Visible)
				{
					continue;
				}

				if (child is View view && view.VerticalOptions.Expands)
				{
					grid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Star });
				}
				else
				{
					grid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
				}

				grid.Add(child);
				grid.SetRow(child, row);

				row += 1;
			}

			return grid;
		}

		static IGridLayout ConvertToColumns(StackLayout stackLayout)
		{
			Grid grid = new AndExpandGrid(stackLayout)
			{
				RowDefinitions = new RowDefinitionCollection { new RowDefinition { Height = GridLength.Star } },
				ColumnDefinitions = new ColumnDefinitionCollection(),
				ColumnSpacing = stackLayout.Spacing
			};

			var column = 0;
			for (int n = 0; n < stackLayout.Count; n++)
			{
				var child = stackLayout[n];

				if (child.Visibility != Visibility.Visible)
				{
					continue;
				}

				if (child is View view && view.HorizontalOptions.Expands)
				{
					grid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Star });
				}
				else
				{
					grid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
				}

				grid.Add(child);
				grid.SetColumn(child, column);

				column += 1;
			}

			return grid;
		}

		class AndExpandGrid : Grid
		{
			protected override void OnChildAdded(Element child)
			{
				// We don't want to actually re-parent the stuff we add to this			
			}

			protected override void OnChildRemoved(Element child, int oldLogicalIndex)
			{
				// Don't do anything here; the base methods will null out Parents, etc., and we don't want that
			}

			public AndExpandGrid(StackLayout layout)
			{
				Margin = layout.Margin;
				Padding = layout.Padding;
			}
		}
	}
}
