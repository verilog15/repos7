﻿#nullable enable
using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.UI.Xaml;

namespace Microsoft.Maui.Platform
{
	internal static class ResourceDictionaryExtensions
	{
		public static T? TryGet<T>(this UI.Xaml.ResourceDictionary? resources, string key)
		{
			if (resources?.ContainsKey(key) == true && resources[key] is T typed)
				return typed;
			return default;
		}

		public static void AddLibraryResources(this UI.Xaml.ResourceDictionary? resources, string key, string uri)
		{
			if (resources == null)
				return;

			var dictionaries = resources.MergedDictionaries;
			if (dictionaries == null)
				return;

			if (!resources.ContainsKey(key))
			{
				dictionaries.Add(new UI.Xaml.ResourceDictionary
				{
					Source = new Uri(uri)
				});
			}
		}

		public static void AddLibraryResources<T>(this UI.Xaml.ResourceDictionary? resources)
			where T : UI.Xaml.ResourceDictionary, new()
		{
			var dictionaries = resources?.MergedDictionaries;
			if (dictionaries == null)
				return;

			var found = false;
			foreach (var dic in dictionaries)
			{
				if (dic is T)
				{
					found = true;
					break;
				}
			}

			if (!found)
			{
				var dic = new T();
				dictionaries.Add(dic);
			}
		}

		internal static void RemoveKeys(this UI.Xaml.ResourceDictionary resources, IEnumerable<string> keys)
		{
			foreach (string key in keys)
			{
				resources.Remove(key);
			}
		}

		internal static void SetValueForAllKey(this UI.Xaml.ResourceDictionary resources, IEnumerable<string> keys, object? value)
		{
			foreach (string key in keys)
			{
				resources[key] = value;
			}
		}
	}
}
