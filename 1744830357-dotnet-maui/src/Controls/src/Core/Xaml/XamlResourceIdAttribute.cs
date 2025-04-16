#nullable disable
using System;
using System.Diagnostics.CodeAnalysis;
using System.Reflection;
using System.Runtime.CompilerServices;

namespace Microsoft.Maui.Controls.Xaml
{
	/// <include file="../../../docs/Microsoft.Maui.Controls.Xaml/XamlResourceIdAttribute.xml" path="Type[@FullName='Microsoft.Maui.Controls.Xaml.XamlResourceIdAttribute']/Docs/*" />
	[AttributeUsage(AttributeTargets.Assembly, Inherited = false, AllowMultiple = true)]
	public sealed class XamlResourceIdAttribute : Attribute
	{
		/// <include file="../../../docs/Microsoft.Maui.Controls.Xaml/XamlResourceIdAttribute.xml" path="//Member[@MemberName='ResourceId']/Docs/*" />
		public string ResourceId { get; set; }
		/// <include file="../../../docs/Microsoft.Maui.Controls.Xaml/XamlResourceIdAttribute.xml" path="//Member[@MemberName='Path']/Docs/*" />
		public string Path { get; set; }
		/// <include file="../../../docs/Microsoft.Maui.Controls.Xaml/XamlResourceIdAttribute.xml" path="//Member[@MemberName='Type']/Docs/*" />
		[DynamicallyAccessedMembers(DynamicallyAccessedMemberTypes.PublicParameterlessConstructor)]
		public Type Type { get; set; }

		/// <include file="../../../docs/Microsoft.Maui.Controls.Xaml/XamlResourceIdAttribute.xml" path="//Member[@MemberName='.ctor']/Docs/*" />
		public XamlResourceIdAttribute(
			string resourceId,
			string path,
			[DynamicallyAccessedMembers(DynamicallyAccessedMemberTypes.PublicParameterlessConstructor)] Type type)
		{
			ResourceId = resourceId;
			Path = path;
			Type = type;
		}

		internal static string GetResourceIdForType(Type type)
		{
			var assembly = type.Assembly;
			foreach (var xria in assembly.GetCustomAttributes<XamlResourceIdAttribute>())
			{
				if (xria.Type == type)
					return xria.ResourceId;
			}
			return null;
		}

		internal static string GetPathForType(Type type)
		{
			var assembly = type.Assembly;
			foreach (var xria in assembly.GetCustomAttributes<XamlResourceIdAttribute>())
			{
				if (xria.Type == type)
					return xria.Path;
			}
			return null;
		}

		internal static string GetResourceIdForPath(Assembly assembly, string path)
		{
			foreach (var xria in assembly.GetCustomAttributes<XamlResourceIdAttribute>())
			{
				if (xria.Path == path)
					return xria.ResourceId;
			}
			return null;
		}

		[return: DynamicallyAccessedMembers(DynamicallyAccessedMemberTypes.PublicParameterlessConstructor)]
		internal static Type GetTypeForResourceId(Assembly assembly, string resourceId)
		{
			foreach (var xria in assembly.GetCustomAttributes<XamlResourceIdAttribute>())
			{
				if (xria.ResourceId == resourceId)
					return xria.Type;
			}
			return null;
		}

		[return: DynamicallyAccessedMembers(DynamicallyAccessedMemberTypes.PublicParameterlessConstructor)]
		internal static Type GetTypeForPath(Assembly assembly, string path)
		{
			foreach (var xria in assembly.GetCustomAttributes<XamlResourceIdAttribute>())
			{
				if (xria.Path == path)
					return xria.Type;
			}
			return null;
		}
	}
}