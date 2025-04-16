#nullable disable
namespace Microsoft.Maui.Controls.PlatformConfiguration.iOSSpecific
{
	using FormsElement = Maui.Controls.SwipeView;

	/// <include file="../../../../docs/Microsoft.Maui.Controls.PlatformConfiguration.iOSSpecific/SwipeView.xml" path="Type[@FullName='Microsoft.Maui.Controls.PlatformConfiguration.iOSSpecific.SwipeView']/Docs/*" />
	public static class SwipeView
	{
		/// <summary>Bindable property for <see cref="SwipeTransitionMode"/>.</summary>
		public static readonly BindableProperty SwipeTransitionModeProperty = BindableProperty.Create("SwipeTransitionMode", typeof(SwipeTransitionMode), typeof(SwipeView), SwipeTransitionMode.Reveal);

		/// <include file="../../../../docs/Microsoft.Maui.Controls.PlatformConfiguration.iOSSpecific/SwipeView.xml" path="//Member[@MemberName='GetSwipeTransitionMode'][1]/Docs/*" />
		public static SwipeTransitionMode GetSwipeTransitionMode(BindableObject element)
		{
			return (SwipeTransitionMode)element.GetValue(SwipeTransitionModeProperty);
		}

		/// <include file="../../../../docs/Microsoft.Maui.Controls.PlatformConfiguration.iOSSpecific/SwipeView.xml" path="//Member[@MemberName='SetSwipeTransitionMode'][1]/Docs/*" />
		public static void SetSwipeTransitionMode(BindableObject element, SwipeTransitionMode value)
		{
			element.SetValue(SwipeTransitionModeProperty, value);
		}

		/// <include file="../../../../docs/Microsoft.Maui.Controls.PlatformConfiguration.iOSSpecific/SwipeView.xml" path="//Member[@MemberName='GetSwipeTransitionMode'][2]/Docs/*" />
		public static SwipeTransitionMode GetSwipeTransitionMode(this IPlatformElementConfiguration<iOS, FormsElement> config)
		{
			return GetSwipeTransitionMode(config.Element);
		}

		/// <include file="../../../../docs/Microsoft.Maui.Controls.PlatformConfiguration.iOSSpecific/SwipeView.xml" path="//Member[@MemberName='SetSwipeTransitionMode'][2]/Docs/*" />
		public static IPlatformElementConfiguration<iOS, FormsElement> SetSwipeTransitionMode(this IPlatformElementConfiguration<iOS, FormsElement> config, SwipeTransitionMode value)
		{
			SetSwipeTransitionMode(config.Element, value);
			return config;
		}
	}
}
