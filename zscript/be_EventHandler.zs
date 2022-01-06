/* Copyright Alexander 'm8f' Kromm (mmaulwurff@gmail.com) 2020, 2022
 *
 * This file is a part of Bubble 'Em.
 *
 * Bubble 'Em is free software: you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * Bubble 'Em is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Bubble 'Em.  If not, see <https://www.gnu.org/licenses/>.
 */

class be_EventHandler : EventHandler
{

  override void WorldThingDied(WorldEvent event)
  {
    if (isValid(event))
    {
      inflate(event.thing);
    }
  }

  override void WorldThingRevived(WorldEvent event)
  {
    if (isValid(event))
    {
      deflate(event.thing);
    }
  }

  override void WorldThingSpawned(WorldEvent event)
  {
    if (event.thing)
    {
      event.thing.bNoExtremeDeath = true;
    }
  }

  override void WorldThingDestroyed(WorldEvent event)
  {
    if (isValid(event))
    {
      transferMagic(event.thing);
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private static void transferMagic(Actor destroyed)
  {
    let magic = findMagic(destroyed);
    if (magic)
    {
      magic.transfer();
    }
  }

  private static bool isValid(WorldEvent event)
  {
    if (event == NULL) return false;
    let thing = event.thing;
    return !(thing == NULL || thing is "PlayerPawn") && thing.bIsMonster;
  }

  private static void inflate(Actor died)
  {
    died.giveInventory(MAGIC_CLASS, 1);

    let magic = findMagic(died);
    if (magic)
    {
      magic.init(died);
    }
  }

  private static void deflate(Actor revived)
  {
    let magic = findMagic(revived);
    if (magic)
    {
      magic.restore();
    }
  }

  private static be_Magic findMagic(Actor a)
  {
    return be_Magic(a.findInventory(MAGIC_CLASS));
  }

  const MAGIC_CLASS = "be_Magic";

} // class be_EventHandler
