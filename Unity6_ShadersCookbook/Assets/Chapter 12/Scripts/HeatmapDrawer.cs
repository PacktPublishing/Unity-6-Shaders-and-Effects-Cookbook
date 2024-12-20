using UnityEngine;

public class HeatmapDrawer : MonoBehaviour
{
    public Vector4[] positions;    // World positions of heatmap points
    public float[] radiuses;       // Radii of influence for each point
    public float[] intensities;    // Intensity values for each point
    public Material material;      // Heatmap material

    void Start()
    {
        UpdateHeatmap();
    }

    void UpdateHeatmap()
    {
        if (material == null || positions.Length != radiuses.Length || positions.Length != intensities.Length)
        {
            Debug.LogWarning("HeatmapDrawer: Invalid data!");
            return;
        }

        // Set the number of points
        material.SetInt("_Points_Length", positions.Length);

        // Pass point positions
        material.SetVectorArray("_Points", positions);

        // Pack radii and intensities into properties array
        Vector4[] properties = new Vector4[positions.Length];
        for (int i = 0; i < positions.Length; i++)
        {
            properties[i] = new Vector4(radiuses[i], intensities[i], 0, 0);
        }
        material.SetVectorArray("_Properties", properties);
    }
}
