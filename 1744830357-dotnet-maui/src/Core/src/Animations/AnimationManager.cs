﻿using System;
using System.Collections.Generic;

namespace Microsoft.Maui.Animations
{
	/// <inheritdoc/>
	public class AnimationManager : IAnimationManager, IDisposable
	{
		readonly List<Animation> _animations = new();
		long _lastUpdate;
		bool _disposedValue;

		/// <summary>
		/// Instantiate a new <see cref="AnimationManager"/> object.
		/// </summary>
		/// <param name="ticker">An instance of <see cref="ITicker"/> that will be used to time the animations.</param>
		public AnimationManager(ITicker ticker)
		{
			_lastUpdate = GetCurrentTick();

			Ticker = ticker;
			Ticker.Fire = OnFire;
		}

		/// <inheritdoc/>
		public ITicker Ticker { get; }

		/// <inheritdoc/>
		public double SpeedModifier { get; set; } = 1;

		/// <inheritdoc/>
		public bool AutoStartTicker { get; set; } = true;

		/// <inheritdoc/>
		public void Add(Animation animation)
		{
			// If animations are disabled, don't do anything
			if (!Ticker.SystemEnabled)
			{
				return;
			}

			if (!_animations.Contains(animation))
				_animations.Add(animation);
			if (!Ticker.IsRunning && AutoStartTicker)
				Start();
		}

		/// <inheritdoc/>
		public void Remove(Animation animation)
		{
			_animations.TryRemove(animation);

			if (_animations.Count == 0)
				End();
		}

		void Start()
		{
			_lastUpdate = GetCurrentTick();
			Ticker.Start();
		}

		void End() =>
			Ticker?.Stop();

		static long GetCurrentTick() =>
			Environment.TickCount & int.MaxValue;

		void OnFire()
		{
			if (!Ticker.SystemEnabled)
			{
				// This is a hack - if we're here, the ticker has detected that animations are no longer enabled,
				// and it's invoked the Fire event one last time because that's the only communication mechanism
				// it currently has available with the AnimationManager. We need to force all the running animations
				// to move to their finished state and stop running.

				ForceFinishAnimations();
				return;
			}

			var now = GetCurrentTick();
			var milliseconds = TimeSpan.FromMilliseconds(now - _lastUpdate).TotalMilliseconds;
			_lastUpdate = now;

			var animations = new List<Animation>(_animations);
			animations.ForEach(OnAnimationTick);

			if (_animations.Count == 0)
				End();

			void OnAnimationTick(Animation animation)
			{
				if (animation.HasFinished)
				{
					_animations.TryRemove(animation);
					animation.RemoveFromParent();
					return;
				}

				animation.Tick(AdjustSpeed(milliseconds));

				if (animation.HasFinished)
				{
					_animations.TryRemove(animation);
					animation.RemoveFromParent();
				}
			}
		}

		protected virtual void Dispose(bool disposing)
		{
			if (!_disposedValue)
			{
				if (disposing && Ticker is IDisposable disposable)
					disposable.Dispose();

				_disposedValue = true;
			}
		}

		/// <inheritdoc/>
		public void Dispose()
		{
			Dispose(disposing: true);
			GC.SuppressFinalize(this);
		}

		void ForceFinishAnimations()
		{
			var animations = new List<Animation>(_animations);
			animations.ForEach(ForceFinish);
			End();

			void ForceFinish(Animation animation)
			{
				animation.ForceFinish();
				_animations.TryRemove(animation);
				animation.RemoveFromParent();
			}
		}

		internal virtual double AdjustSpeed(double elapsedMilliseconds)
		{
			return elapsedMilliseconds * SpeedModifier;
		}
	}
}