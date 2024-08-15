using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.SceneManagement;

/// <summary>
/// Automatically toggles a ScriptableRendererFeature when 
/// switching scenes in the Unity Editor.
/// </summary>
[InitializeOnLoad]
public static class ToggleRendererFeature
{
    /// <summary>
    /// Stores the reference to the renderer feature 
    /// from the previous scene.
    /// </summary>
    static ScriptableRendererFeature oldFeature;

    /// <summary>
    /// Static constructor subscribes to the 
    /// scene change event in edit mode.
    /// </summary>
    static ToggleRendererFeature()
    {
        EditorSceneManager.activeSceneChangedInEditMode +=
            OnActiveSceneChanged;
    }

    /// <summary>
    /// Called when the active scene is changed in edit mode.
    /// </summary>
    /// <param name="oldScene">The previous active scene.</param>
    /// <param name="newScene">The new active scene.</param>
    private static void OnActiveSceneChanged(Scene oldScene,
                                             Scene newScene)
    {
        // Disable the renderer feature from the old scene
        if (oldFeature != null)
        {
            oldFeature.SetActive(false);
            oldFeature = null;
        }

        // Find the target component in the new scene
        var targetComponent = GameObject
            .FindAnyObjectByType<SceneFeature>();

        if (targetComponent != null)
        {
            // Enable the renderer feature in the new scene
            targetComponent.feature.SetActive(true);

            // Store the reference to disable it later
            oldFeature = targetComponent.feature;
        }
    }
}