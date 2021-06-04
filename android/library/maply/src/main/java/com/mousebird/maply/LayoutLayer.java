/*  LayoutLayer.java
 *  WhirlyGlobeLib
 *
 *  Created by Steve Gifford on 6/2/14.
 *  Copyright 2011-2021 mousebird consulting
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

package com.mousebird.maply;

import android.os.Handler;

import java.lang.ref.WeakReference;

/**
 * The layout layer runs every so often to layout text and marker objects on the screen.
 * You don't need to create one of these, MaplyController does that.
 */
class LayoutLayer extends Layer implements LayerThread.ViewWatcherInterface
{
	LayoutLayer(BaseController inMaplyControl,LayoutManager inLayoutManager)
	{
		maplyControl = new WeakReference<>(inMaplyControl);
		layoutManager = inLayoutManager;
	}
	
	public void startLayer(LayerThread inLayerThread)
	{
		super.startLayer(inLayerThread);

		scheduleUpdate();

		BaseController control = maplyControl.get();
		LayerThread layerThread = (control != null) ? control.getLayerThread() : null;
		if (layerThread != null) {
			layerThread.addWatcher(this);
		}
	}
	
	public void shutdown()
	{
		cancelUpdate();

		layoutManager.clearClusterGenerators();
	}

	// Called when the view state changes
	@Override
	public void viewUpdated(ViewState newViewState) {
		// This pushes back the update, which is what we want
		// We'd prefer to update 0.2s after the user stops moving
		if (viewState == null || !viewState.equals(newViewState))
		{
			cancelUpdate();
			viewState = newViewState;

			final double elapsed = (System.nanoTime() - lastUpdateTime) / 1.0e9;
			if (elapsed > getMaxLagTime()) {
				runUpdate();
			} else {
				scheduleUpdate();
			}
		}
	}

	@Override
	public float getMinTime() {
		return DelayPeriod / 1000.0f;
	}

	@Override
	public float getMaxLagTime() {
		// Want an update no less often than this
		return 1.0f;
	}

	public void addClusterGenerator(ClusterGenerator generator) {
		final Point2d clusterSize = generator.clusterLayoutSize();
		synchronized (this) {
			layoutManager.addClusterGenerator(generator,
			                                  generator.clusterNumber(),
			                                  generator.selectable(),
			                                  clusterSize.getX(),clusterSize.getY());
		}
	}

	// Schedule an update if there isn't one already
	private void scheduleUpdate()
	{
		synchronized(this)
		{
			cancelUpdate();
			if (maplyControl.get() != null && layoutManager.hasChanges()) {
				// Triggers if we haven't moved again in a while
				updateHandle = layerThread.addDelayedTask(updateRun, DelayPeriod);
			}
			// Run this again in twice as long
			checkHandle = layerThread.addDelayedTask(checkRun, 2 * DelayPeriod);
		}
	}
	
	// Cancel an update if there's one scheduled
	private void cancelUpdate()
	{
		synchronized(this)
		{
			if (updateHandle != null) {
				updateHandle.removeCallbacks(updateRun);
				updateHandle = null;
			}
			if (checkHandle != null) {
				checkHandle.removeCallbacks(checkRun);
				checkHandle = null;
			}
		}
	}
	
	// Actually run the layout update
	private void runUpdate()
	{
		synchronized(this) {
			cancelUpdate();
		}

		ChangeSet changes = new ChangeSet();
		layoutManager.updateLayout(viewState, changes);

		BaseController control = maplyControl.get();
		Scene scene = (control != null) ? control.scene : null;
		if (scene != null) {
			control.scene.addChanges(changes);
		}

		lastUpdateTime = System.nanoTime();

		scheduleUpdate();
	}

	private static final int DelayPeriod = 200;

	private final WeakReference<BaseController> maplyControl;
	private final LayoutManager layoutManager;
	private final Runnable updateRun = this::runUpdate;
	private final Runnable checkRun = this::scheduleUpdate;

	private ViewState viewState = null;
	private Handler updateHandle = null;
	private Handler checkHandle = null;
	private long lastUpdateTime = System.nanoTime();
}
