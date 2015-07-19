/*
 * Scratch Project Editor and Player
 * Copyright (C) 2015 Massachusetts Institute of Technology
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

package Logging {
public class Log {

	public const logBuffer:Vector.<LogEntry> = new <LogEntry>[];

	private var fixedBuffer:Boolean;
	private var nextIndex:uint;

	// If messageCount is 0, keep all logged messages. Otherwise throw out old messages once `messageCount` is reached.
	public function Log(messageCount:uint = 100) {
		fixedBuffer = (messageCount > 0);
		if (fixedBuffer) {
			logBuffer.length = messageCount;
		}
		nextIndex = 0;
	}

	// Add a new entry to the log.
	public function log(severity:String, messageKey:String, extraData:Object = null):LogEntry {
		var entry:LogEntry = logBuffer[nextIndex];
		if (entry) {
			// Reduce GC impact by replacing the contents of existing entries
			entry.setAll(severity, messageKey, extraData);
		}
		else {
			// Either we're not in fixedBufer mode or we haven't yet filled the buffer.
			entry = new LogEntry(severity, messageKey, extraData);
			logBuffer[nextIndex] = entry;
		}
		++nextIndex;
		if (fixedBuffer) {
			nextIndex %= logBuffer.length;
		}
		return entry;
	}

	// Generate a JSON-compatible object representing the contents of the log.
	public function toJSON():Object {
		var baseIndex:uint = fixedBuffer ? nextIndex : 0;
		var count:uint = logBuffer.length;
		var jsonArray:Array = [];
		for (var index:uint = 0; index < count; ++index) {
			var entry:LogEntry = logBuffer[(baseIndex + index) % count];
			// If we're in fixedBuffer mode and nextIndex hasn't yet wrapped then there will be null entries
			if (entry) {
				jsonArray.push(entry.toJSON());
			}
		}
		return jsonArray;
	}
}
}
