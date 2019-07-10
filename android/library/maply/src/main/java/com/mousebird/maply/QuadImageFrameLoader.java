

package com.mousebird.maply;

import android.os.Handler;

/**
 * The Maply Quad Image Frame Loader is for paging individual frames of image pyramids.
 * <br>
 * This works much like the Quad Image Loader, but handles more than one frame.  You can animate
 * between the frames with the QuadImageFrameAnimator.
 */
public class QuadImageFrameLoader extends QuadImageLoaderBase
{
    boolean valid = false;

    public QuadImageFrameLoader(final SamplingParams params,TileInfoNew inTileInfos[],BaseController control)
    {
        super(control, params, inTileInfos.length);
        tileInfos = inTileInfos;

        valid = true;
        Handler handler = new Handler(control.getActivity().getMainLooper());
        handler.post(new Runnable() {
            @Override
            public void run() {
                if (!valid)
                    return;

                delayedInit(params);
            }
        });
    }

    /**
     * Set the interpolated location within the array of frames.
     * <br>
     * Each set of frames can be accessed from [0.0,numFrames].  Images will be interpolated between
     * those values and may be snapped if data has not yet loaded.
     * <br>
     * This value is used once per frame, so feel free to call this as much as you'd like.
     */
    public void setCurrentImage(double where)
    {
//        double curFrame = std::min(std::max(where,0.0),(double)([loader->frameInfos count]-1));
        double curFrame = Math.min(Math.max(where,0.0),(double)(tileInfos.length-1));

        setCurrentImageNative(where);
    }

    protected native void setCurrentImageNative(double where);

    /**
     * Number of tile sources passed in as individual frames.
     */
    public int getNumFrames() {
        return tileInfos.length;
    }

    @Override
    public void shutdown() {
        valid = false;

        super.shutdown();
    }

    /**
     * The Maply Quad Image Frame Loader can generation per-frame stats.  These are them.
     */
    public class FrameStats
    {
        /**
         * Number of tiles this frame is in (loading and loaded)
         */
        public int totalTiles;

        /**
         * Number of tiles this frame has yet to load
         */
        public int tilesToLoad;
    }

    /**
     * Stats generated by the Maply Quad Image Frame Loader.
     */
    public class Stats
    {
        /**
         * Total number of tiles managed by the loader
         */
        public int numTiles = 0;

        /**
         * Per frame stats for current loading state
         */
        public FrameStats[] frameStats = null;
    }

    /**
     * Pull out the per-frame instantaneous stats.
     */
    public Stats getStats()
    {
        int numFrames = getNumFrames();
        if (numFrames == 0)
            return null;

        Stats stats = new Stats();
        stats.frameStats = new FrameStats[numFrames];
        int totalTiles[] = new int[numFrames];
        int tilesToLoad[] = new int[numFrames];

        // Fetch the data like this because I'm lazy
        stats.numTiles = getStatsNative(totalTiles, tilesToLoad);
        for (int ii=0;ii<numFrames;ii++)
        {
            FrameStats frameStats = new FrameStats();
            frameStats.tilesToLoad = tilesToLoad[ii];
            frameStats.totalTiles = totalTiles[ii];
            stats.frameStats[ii] = frameStats;
        }

        return stats;
    }

    private native int getStatsNative(int[] totalTiles,int[] tilesToLoad);
}