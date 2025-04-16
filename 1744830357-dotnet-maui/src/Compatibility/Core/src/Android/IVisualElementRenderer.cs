using System;
using System.ComponentModel;
using Android.Views;
using Microsoft.Maui.Controls.Platform;
using ALayoutChangeEventArgs = Android.Views.View.LayoutChangeEventArgs;
using AView = Android.Views.View;

namespace Microsoft.Maui.Controls.Compatibility.Platform.Android
{
	public interface IVisualElementRenderer : IRegisterable, IDisposable
	{
		VisualElement Element { get; }

		VisualElementTracker Tracker { get; }

		AView View { get; }

		event EventHandler<VisualElementChangedEventArgs> ElementChanged;

		event EventHandler<PropertyChangedEventArgs> ElementPropertyChanged;

		SizeRequest GetDesiredSize(int widthConstraint, int heightConstraint);

		void SetElement(VisualElement element);

		void SetLabelFor(int? id);

		void UpdateLayout();
	}
}