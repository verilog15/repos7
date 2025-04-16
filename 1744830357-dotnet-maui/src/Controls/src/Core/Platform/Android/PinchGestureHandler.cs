#nullable disable
using System;
using System.Linq;
using Microsoft.Maui.Controls.Internals;
using Microsoft.Maui.Graphics;

namespace Microsoft.Maui.Controls.Platform
{
	internal class PinchGestureHandler
	{
		double _pinchStartingScale = 1;

		public PinchGestureHandler(Func<View> getView)
		{
			GetView = getView;
		}

		Func<View> GetView { get; }

		// A View can have at most one pinch gesture, so we just need to look for one (or none)
		IPinchGestureController PinchGesture => GetView()?.GestureRecognizers.OfType<PinchGestureRecognizer>()
			.FirstOrDefault();

		public bool OnPinch(float scale, Point scalePoint)
		{
			View view = GetView();

			if (view == null)
				return false;

			IPinchGestureController pinchGesture = PinchGesture;
			if (pinchGesture == null)
				return true;

			var scalePointTransformed = new Point(scalePoint.X / view.Width, scalePoint.Y / view.Height);
			pinchGesture.SendPinch(view, 1 + (scale - 1) * _pinchStartingScale, scalePointTransformed);

			return true;
		}

		public void OnPinchEnded()
		{
			View view = GetView();

			if (view == null)
				return;

			IPinchGestureController pinchGesture = PinchGesture;
			pinchGesture?.SendPinchEnded(view);
		}

		public bool OnPinchStarted(Point scalePoint)
		{
			View view = GetView();

			if (view == null)
				return false;

			IPinchGestureController pinchGesture = PinchGesture;
			if (pinchGesture == null)
				return false;

			_pinchStartingScale = view.Scale;

			var scalePointTransformed = new Point(scalePoint.X / view.Width, scalePoint.Y / view.Height);

			pinchGesture.SendPinchStarted(view, scalePointTransformed);
			return true;
		}
	}
}