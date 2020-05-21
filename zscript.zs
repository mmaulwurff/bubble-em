version 4.3.3

class be_Bubble : Actor
{
  Default
  {
    +Nogravity;
    +NoInteraction;

    FloatBobStrength 0.2;

    RenderStyle 'Stencil';
    Alpha  0;
    XScale 6.66;
    YScale 6.66;
  }

  States
  {
    Spawn:
      BE_2 A 1;
      Loop;
  }
}

class be_Animator : Inventory
{
  void init()
  {
    if (owner == NULL) { return; }

    mOrigScale = owner.scale;
    mLifetime  = 0;

    Vector3 bubblePos = owner.pos + (0, 0, owner.height / 2);
    mBubble = be_Bubble(Actor.Spawn("be_Bubble", bubblePos));
    mOrigBubbleScale = mBubble.scale;
    mBubble.FloatBobPhase = owner.FloatBobPhase;
    let shade = String.format( "%x%x%x%x%x%x"
                             , random(6, 0xb)
                             , random(6, 0xb)
                             , random(6, 0xb)
                             , random(6, 0xb)
                             , random(6, 0xb)
                             , random(6, 0xb)
                             );
    mBubble.setShade(shade);
  }

  override
  void Tick()
  {
    if (owner == NULL) { return; }

    if (mLifetime < DURATION)
    {
      double ratio      = double(mLifetime) / DURATION;
      double scaleRatio = (1 - ratio) * (1 - TARGET_SCALE) + TARGET_SCALE;

      owner  .scale = scaleRatio * mOrigScale;
      mBubble.scale = scaleRatio * mOrigBubbleScale;
      mBubble.alpha = ratio * 0.6;
      mBubble.setOrigin(owner.pos + (0, 0, owner.height * scaleRatio / 2), true);
    }
    else if (mLifetime == DURATION)
    {
      mBubble.bFloatBob = true;
    }

    ++mLifetime;
  }

  const DURATION = 35 / 2;
  const TARGET_SCALE = 0.3;

  Vector2   mOrigScale;
  Vector2   mOrigBubbleScale;
  int       mLifetime;
  be_Bubble mBubble;
}

class be_EventHandler : EventHandler
{
  override void WorldThingDied(WorldEvent event)
  {
    Actor died = event.thing;

    // Expect the unexpected.
    if (died == NULL)
    {
      return;
    }

    // Can't bubble yourself.
    if (died is "PlayerPawn")
    {
      return;
    }

    died.A_SetRenderStyle(0.0, STYLE_None);
    died.deathSound = "";

    Vector3 pos = died.pos + (0, 0, 10);

    Actor pretender = Actor.Spawn(died.getClass(), pos);
    pretender.angle = died.angle;

    pretender.giveInventory("be_Animator", 1);
    let animator = be_Animator(pretender.findInventory("be_Animator"));
    animator.init();

    level.total_monsters -= pretender.bCountKill;

    pretender.FloatBobStrength = 0.2;
    pretender.A_SetTics(int.Max);
    pretender.bFloatbob = true;
    pretender.bShootable = false;
    pretender.bNoInteraction = true;
    pretender.bNogravity = true;
  }

}
