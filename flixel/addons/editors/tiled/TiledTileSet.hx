package flixel.addons.editors.tiled;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import haxe.xml.Fast;

/**
 * Copyright (c) 2013 by Samuel Batista
 * (original by Matt Tuttle based on Thomas Jahn's. Haxe port by Adrien Fischer)
 * This content is released under the MIT License.
 */
class TiledTileSet
{
	public var firstGID:Int;
	public var name:String;
	public var tileWidth:Int;
	public var tileHeight:Int;
	public var spacing:Int;
	public var margin:Int;
	public var imageSource:String;
	
	// Available only after immage has been assigned:
	public var numTiles:Int;
	public var numRows:Int;
	public var numCols:Int;
	
	private var _tileProps:Array<TiledPropertySet>;
	
	public function new(data:Dynamic)
	{
		var node:Fast, source:Fast;
		numTiles = 0xFFFFFF;
		numRows = numCols = 1;
		
		// Use the correct data format
		if (Std.is(data, Fast))
		{
			source = data;
		}
		else if (Std.is(data, ByteArray))
		{
			source = new Fast(Xml.parse(data.toString()));
			source = source.node.tileset;
		}
		else 
		{
			throw "Unknown TMX tileset format";
		}
		
		firstGID = (source.has.firstgid) ? Std.parseInt(source.att.firstgid) : 1;
		
		// check for external source
		if (source.has.source)
		{
			
		}
		// internal
		else 
		{
			var node:Fast = source.node.image;
			imageSource = node.att.source;
			
			var imgWidth = Std.parseInt(node.att.width);
			var imgHeight = Std.parseInt(node.att.height);
			
			name = source.att.name;
			
			if (source.has.tilewidth) 
			{
				tileWidth = Std.parseInt(source.att.tilewidth);
			}
			if (source.has.tileheight) 
			{
				tileHeight = Std.parseInt(source.att.tileheight);
			}
			if (source.has.spacing) 
			{
				spacing = Std.parseInt(source.att.spacing);
			}
			if (source.has.margin) 
			{
				margin = Std.parseInt(source.att.margin);
			}
			
			// read properties
			_tileProps = new Array<TiledPropertySet>();
			
			for (node in source.nodes.tile)
			{
				if (!node.has.id)
				{
					continue;
				}
				
				var id:Int = Std.parseInt(node.att.id);
				_tileProps[id] = new TiledPropertySet();
				
				for (prop in node.nodes.properties)
				{
					_tileProps[id].extend(prop);
				}
			}
			
			if (tileWidth > 0 && tileHeight > 0)
			{
				numRows = cast(imgWidth / tileWidth);
				numCols = cast(imgHeight / tileHeight);
				numTiles = numRows * numCols;
			}
		}
	}
	
	inline public function hasGid(Gid:Int):Bool
	{
		return (Gid >= firstGID) && Gid < (firstGID + numTiles);
	}
	
	inline public function fromGid(Gid:Int):Int
	{
		return Gid - (firstGID - 1);
	}
	
	inline public function toGid(ID:Int):Int
	{
		return firstGID + ID;
	}

	public function getPropertiesByGid(Gid:Int):TiledPropertySet
	{
		if (_tileProps != null)
		{
			return _tileProps[Gid - firstGID];
		}
		
		return null;
	}
	
	inline public function getProperties(ID:Int):TiledPropertySet
	{
		return _tileProps[ID];
	}
	
	inline public function getRect(ID:Int):Rectangle
	{
		// TODO: consider spacing & margin
		return new Rectangle((ID % numCols) * tileWidth, (ID / numCols) * tileHeight);
	}
}