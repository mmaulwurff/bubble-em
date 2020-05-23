version 4.3.3

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
  }

  States
  {
    Spawn:
      BE_2 A 1;
      loop;
  }

} // class be_Bubble

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
    let pretender = Actor.Spawn(mOriginal.getClass(), pos);

    mPretender = pretender;

    pretender.angle            = mOriginal.angle;
    pretender.floatBobStrength = 0.2;
    pretender.bFloatBob        = true;
    pretender.bShootable       = false;
    pretender.bNoInteraction   = true;
    pretender.bNogravity       = true;
    pretender.bIsMonster       = false;
    pretender.A_SetTics(int.Max);
    mOrigScale = pretender.scale;

    level.total_monsters -= pretender.bCountKill;
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
    double bubbleScale = max(mPretender.radius / 20, mPretender.height / 40);
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

} // class be_Magic

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

  private void transferMagic(Actor destroyed)
  {
    let magic = findMagic(destroyed);
    if (magic)
    {
      magic.transfer();
    }
  }

  private bool isValid(WorldEvent event)
  {
    return !(event.thing == NULL || event.thing is "PlayerPawn");
  }

  private void inflate(Actor died)
  {
    died.giveInventory(MAGIC_CLASS, 1);

    let magic = findMagic(died);
    if (magic)
    {
      magic.init(died);
    }
  }

  private void deflate(Actor revived)
  {
    let magic = findMagic(revived);
    if (magic)
    {
      magic.restore();
    }
  }

  private be_Magic findMagic(Actor a)
  {
    return be_Magic(a.findInventory(MAGIC_CLASS));
  }

  const MAGIC_CLASS = "be_Magic";

} // class be_EventHandler
