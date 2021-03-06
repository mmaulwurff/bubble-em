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

class be_Magic : Inventory
{

  void init(Actor original)
  {
    initOriginal(original);
    initPretender();
    initBubble();

    mLifetime  = 0;
  }

  void restore()
  {
    mOriginal.A_SetRenderStyle(mOriginalAlpha, mOriginalRenderStyle);
    mOriginal.A_StartSound("be/pop");

    mPretender.destroy();
    mBubble.destroy();
    GoAwayAndDie();
  }

  void transfer()
  {
    mOriginal.RemoveInventory(self);
    callTryPickup(mPretender);
  }

  private void initPretender()
  {
    let pos       = makePretenderPos();
    let pretender = Actor.Spawn(mOriginal.getClass(), pos, false);

    mPretender = pretender;

    pretender.angle            = mOriginal.angle;
    pretender.floatBobStrength = 0.2;
    pretender.bFloatBob        = true;
    pretender.bShootable       = false;
    pretender.bNoInteraction   = true;
    pretender.bNogravity       = true;
    pretender.bIsMonster       = false;
    pretender.bForceXYBillboard = true;
    pretender.bRollSprite      = true;
    pretender.bRollCenter      = true;
    pretender.health = -1;
    pretender.A_SetTics(int.Max);
    mOrigScale = pretender.scale;
    mRoll = random(-4, 4) / 10.0;

    level.total_monsters -= pretender.bCountKill;

    pretender.A_StartSound("be/swoosh");
  }

  private void initOriginal(Actor original)
  {
    mOriginal            = original;
    mOriginalRenderStyle = original.GetRenderStyle();
    mOriginalAlpha       = original.alpha;

    mOriginal.A_SetRenderStyle(0.0, STYLE_None);
    // no need to save, it won't be used anymore.
    mOriginal.deathSound = "";
  }

  private void initBubble()
  {
    Vector3 bubblePos = makeBubblePos();
    mBubble = Actor.Spawn("be_Bubble", bubblePos);
    double bubbleScale = max(mPretender.radius / 16, mPretender.height / 32);
    mOrigBubbleScale = mBubble.scale * bubbleScale;
    mBubble.floatBobPhase = mPretender.floatBobPhase;
    let shade = String.format( "%x%x%x%x%x%x"
                             , random(9, 0xc)
                             , random(9, 0xc)
                             , random(9, 0xc)
                             , random(9, 0xc)
                             , random(9, 0xc)
                             , random(9, 0xc)
                             );
    mBubble.setShade(shade);
  }

  override void Tick()
  {
    if (mBubble == NULL || mPretender == NULL)
    {
      return;
    }

    if (mLifetime < DURATION)
    {
      double ratio      = double(mLifetime) / DURATION;
      double scaleRatio = (1 - ratio) * (1 - TARGET_SCALE) + TARGET_SCALE;

      mPretender.scale = scaleRatio * mOrigScale;
      mBubble.scale = scaleRatio * mOrigBubbleScale;
      mBubble.alpha = ratio * 0.6;
      mBubble.setOrigin(mPretender.pos + (0, 0, mPretender.height * scaleRatio / 2), true);

      ++mLifetime;
    }
    else if (mLifetime == DURATION)
    {
      mBubble.bFloatBob = true;
    }

    // These things have to be set all the time.
    mPretender.A_SetTics(int.Max);
    mPretender.bFloatBob = true;
    mPretender.A_SetRoll(mPretender.roll + mRoll);

    if (mOriginal && mOriginal.vel != (0, 0, 0))
    {
      mPretender.setOrigin(makePretenderPos(), true);
      mBubble   .setOrigin(makeBubblePos(), true);
    }
  }

  private Vector3 makeBubblePos()
  {
    return mPretender.pos + (0, 0, mPretender.height * TARGET_SCALE / 2);
  }

  private Vector3 makePretenderPos()
  {
    return mOriginal.pos + (0, 0, 10);
  }

  const DURATION = 35 / 4;
  const TARGET_SCALE = 0.1;

  private Vector2   mOrigScale;
  private Vector2   mOrigBubbleScale;
  private int       mLifetime;

  private int mOriginalRenderStyle;
  private double mOriginalAlpha;

  private Actor mBubble;
  private Actor mPretender;
  private Actor mOriginal;

  private double mRoll;

} // class be_Magic
