using UnityEngine;

[ExecuteAlways]
public class FurLayerGenerator : MonoBehaviour
{
    [Tooltip("Shared material for all layers")]
    public Material baseMaterial;

    [Tooltip("Starting FUR_MULTIPLIER value")]
    public float startValue = 0.05f;

    [Tooltip("Step size for FUR_MULTIPLIER")]
    public float stepSize = 0.05f;

    /// <summary>
    /// Default render queue for fur layers
    /// </summary>
    private int baseRenderQueue = 3000;


    [Tooltip("Toggle for debug mode, when in debug mode will regenerate the objects at runtime")]
    public bool debugMode = true;

    /// <summary>
    /// Time interval for updates
    /// </summary>
    private float updateInterval = 0.1f;

    /// <summary>
    /// Timer to track update intervals
    /// </summary>
    private float timeSinceLastUpdate = 0.0f;


    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    private void Update()
    {
        // Ensure safe execution in edit mode
        if (debugMode && isActiveAndEnabled)
        {
            timeSinceLastUpdate += Time.deltaTime;
            if (timeSinceLastUpdate >= updateInterval)
            {
                GenerateFurLayers();
                timeSinceLastUpdate = 0.0f;
            }
        }
    }


    [ContextMenu("Generate Fur Layers")]
    public void GenerateFurLayers()
    {
        // Validate inputs
        if (baseMaterial == null)
        {
            return;
        }

        // Clear existing fur layers 
        ClearExistingFurLayers();

        // Calculate the total number of layers based on step size
        int layerCount = Mathf.CeilToInt((1 - startValue) / stepSize);

        // Generate fur layers
        CreateFurLayers(layerCount);
    }

    /// <summary>
    /// Removes any child objects that contain "FurLayer" in their name.
    /// </summary>
    private void ClearExistingFurLayers()
    {
        for (int i = transform.childCount - 1; i >= 0; i--)
        {
            Transform child = transform.GetChild(i);
            if (child.name.Contains("FurLayer"))
            {
                DestroyImmediate(child.gameObject);
            }
        }
    }

/// <summary>
/// Creates the fur layers and assigns the appropriate materials and meshes.
/// </summary>
/// <param name="layerCount">Number of layers to create.</param>
private void CreateFurLayers(int layerCount)
{
    MeshFilter parentMeshFilter = GetComponent<MeshFilter>();
    if (parentMeshFilter == null || parentMeshFilter.sharedMesh == null)
    {
        Debug.LogWarning("No parent MeshFilter or sharedMesh found. Cannot generate fur layers.");
        return;
    }

    for (int i = 0; i < layerCount; i++)
    {
        float furMultiplier = startValue + (stepSize * i);

        // Stop if we exceed maximum value
        if (furMultiplier > 1.0f)
        {
            break; 
        }

        CreateSingleFurLayer(i, furMultiplier, parentMeshFilter.sharedMesh);
    }
}

    /// <summary>
    /// Creates a single fur layer GameObject with the given multiplier and mesh.
    /// </summary>
    /// <param name="index">Layer index, used for naming and ordering.</param>
    /// <param name="furMultiplier">The FUR_MULTIPLIER for this layer.</param>
    /// <param name="mesh">The mesh to assign to this layer's MeshFilter.</param>
    private void CreateSingleFurLayer(int index, float furMultiplier, Mesh mesh)
    {
        GameObject layer = new GameObject($"FurLayer_{index}");
        layer.transform.SetParent(transform);
        layer.transform.localPosition = Vector3.zero;
        layer.transform.localRotation = Quaternion.identity;
        layer.transform.localScale = Vector3.one;

        MeshFilter meshFilter = layer.AddComponent<MeshFilter>();
        meshFilter.sharedMesh = mesh;

        MeshRenderer meshRenderer = layer.AddComponent<MeshRenderer>();
        Material layerMaterial = CreateLayerMaterial(furMultiplier, index);
        meshRenderer.sharedMaterial = layerMaterial;
    }

    /// <summary>
    /// Creates a new material instance for a specific fur layer and sets its properties.
    /// </summary>
    /// <param name="furMultiplier">FUR_MULTIPLIER for this layer.</param>
    /// <param name="index">Layer index, used to adjust renderQueue.</param>
    /// <returns>A new Material instance configured for this layer.</returns>
    private Material CreateLayerMaterial(float furMultiplier, int index)
    {
        Material layerMaterial = new Material(baseMaterial);
        layerMaterial.SetFloat("_FUR_MULTIPLIER", furMultiplier);
        layerMaterial.renderQueue = baseRenderQueue + index;
        return layerMaterial;
    }
}
