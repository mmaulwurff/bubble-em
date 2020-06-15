/* Copyright Alexander 'm8f' Kromm (mmaulwurff@gmail.com) 2020
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

class be_Bubble : Actor
{

  Default
  {
    +Nogravity;
    +NoInteraction;
    +ForceXYBillboard;

    FloatBobStrength 0.2;

    RenderStyle 'Stencil';
    Alpha  0;
    XScale 6.66;
    YScale 6.66;

    Tag "Bubble";
  }

  States
  {
    Spawn:
      BE_2 A 1;
      loop;
  }

} // class be_Bubble
