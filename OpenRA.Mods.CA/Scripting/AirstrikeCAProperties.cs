#region Copyright & License Information
/**
 * Copyright (c) The OpenRA Combined Arms Developers (see CREDITS).
 * This file is part of OpenRA Combined Arms, which is free software.
 * It is made available to you under the terms of the GNU General Public License
 * as published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version. For more information, see COPYING.
 */
#endregion

using System.Linq;
using OpenRA.Mods.CA.Traits;
using OpenRA.Scripting;
using OpenRA.Traits;

namespace OpenRA.Mods.CA.Scripting
{
	[ScriptPropertyGroup("Support Powers")]
	public class AirstrikeCAProperties : ScriptActorProperties, Requires<AirstrikePowerCAInfo>
	{
		readonly AirstrikePowerCA ap;

		public AirstrikeCAProperties(ScriptContext context, Actor self)
			: base(context, self)
		{
			ap = self.TraitsImplementing<AirstrikePowerCA>().First();
		}

		[Desc("Activate the actor's Airstrike Power. Returns the aircraft that will attack.")]
		public Actor[] TargetAirstrike(WPos target, WAngle? facing = null)
		{
			return ap.SendAirstrike(Self, target, facing);
		}
	}
}
