/*  ViewState.java
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

/**
 * The view state encapsulates what's in a view at a certain point in time.
 * It's here so we can pass that around without fear of making a mess.
 * <p>
 * In general, toolkit users shouldn't need to interact with these.
 */
public class ViewState
{
	protected ViewState()
	{
	}

	@Override
	public boolean equals(Object o) {
		if (this == o) return true;
		if (!(o instanceof ViewState)) return false;
		ViewState viewState = (ViewState) o;
		return nativeHandle == viewState.nativeHandle || isEqual(viewState);
	}

	/**
	 * Compare two view states and return true if they're equal.
	 * 
	 * @param viewState View state to compare.
	 * @return Return true if the view states are the same.
	 */
	public native boolean isEqual(ViewState viewState);

	/**
	 * Return the eye position.
	 */
	public native Point3d getEyePos();

	public void finalize()
	{
		dispose();
	}

	static
	{
		nativeInit();
	}
	private static native void nativeInit();
	native void dispose();
	private long nativeHandle;
}
