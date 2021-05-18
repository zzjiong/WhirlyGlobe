/*
 *  CoordSystem.java
 *  WhirlyGlobeLib
 *
 *  Created by Steve Gifford on 6/2/14.
 *  Copyright 2011-2014 mousebird consulting
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
 *
 */

package com.mousebird.maply;

/**
 * The coord system is a very simple representation of the coordinate
 * systems supported by WhirlyGlobe-Maply. Very few moving parts are
 * accessible at this level.  In general, you'll want to instantiate
 * one of the subclasses and pass it around to Mapy objects as needed.
 *
 */
public class CoordSystem
{
	/**
	 * Only ever called by the subclass.  Don't use this directly please.
	 */
	protected CoordSystem()
	{
	}
	
	public void finalize()
	{
		dispose();
	}
		
	/**
	 * Lower left corner of the bounding box in local coordinates.
	 */
	public Point3d ll = null;
	/**
	 * Upper right corner of the bounding box in local coordinates.
	 */
	public Point3d ur = null;

	/**
	 * Return the valid bounding box for the coordinate system.
	 * null means everywhere is valid.
     */
	public Mbr getBounds()
	{
		return isValid() ? new Mbr(ll.getX(),ll.getY(), ur.getX(),ur.getY()) : null;
	}

	/**
	 * Returns true if the corner points are set and not identical
	 */
	public boolean isValid() {
		return (ll != null && ur != null && ll.getX() < ur.getX());
	}
	/**
	 * Set the bounding box for the coordinate system.
	 * @param mbr
     */
	public void setBounds(Mbr mbr)
	{
		ll = new Point3d(mbr.ll.getX(),mbr.ll.getY(),0.0);
		ur = new Point3d(mbr.ur.getX(),mbr.ur.getY(),0.0);
	}

	/**
	 * Convert from WGS84 longitude/latitude coordinates to the local coordinate system.
	 * 
	 * @param pt The input coordinate in longitude/latitude WGS84 radians.  Yes, radians.
	 * @return A point in the local coordinate system.
	 */
	public native Point3d geographicToLocal(Point3d pt);
	
	/**
	 * Convert from the local coordinate system to WGS84 longitude/latitude in radians.
	 * 
	 * @param pt A point in the local coordinate system.
	 * @return A coordinate in longitude/latitude WGS84 radians.  Yes, radians.
	 */
	public native Point3d localToGeographic(Point3d pt);

	/**
	 * Convert from the local coordinate system to Geocentric
	 *
	 * @param pt A point in the local coordinate system.
	 * @return A coordinate in geocentric.
	 */
	public native Point3d localToGeocentric(Point3d pt);

	/**
	 * Convert from geocentric to the local coordinate system.
	 *
	 * @param pt A point in geocentric
	 * @return A coordinate in the local coordinate system.
	 */
	public native Point3d geocentricToLocal(Point3d pt);

	/**
	 * Convert the coordinate between systems.
	 * @param inSystem The system the coordinate is in.
	 * @param outSystem The system the coordinate you want it in.
	 * @param inCoord The coordinate.
     * @return Returns the coordinate in the outSystem.
     */
	public static native Point3d CoordSystemConvert3d (CoordSystem inSystem, CoordSystem outSystem, Point3d inCoord);
	
	static
	{
		nativeInit();
	}
	private static native void nativeInit();
	native void initialise();
	native void dispose();
	private long nativeHandle;
}
