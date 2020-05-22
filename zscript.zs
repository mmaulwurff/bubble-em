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

} // class be_Bubble

class be_Magic : Inventory
{

  void init(Actor pretender, Actor original)
  {
    initOriginal(original);
    initPretender(pretender);
    initBubble();

    mLifetime  = 0;
  }

  private void initPretender(Actor pretender)
  {
    mPretender = pretender;

    pretender.angle            = mOriginal.angle;
    pretender.floatBobStrength = 0.2;
    pretender.bFloatbob        = true;
    pretender.bShootable       = false; // ?
    pretender.bNoInteraction   = true;
    pretender.bNogravity       = true;
    pretender.A_SetTics(int.Max);
    mOrigScale = owner.scale;

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
    Vector3 bubblePos = owner.pos + (0, 0, owner.height / 2);
    mBubble = Actor.Spawn("be_Bubble", bubblePos);
    double bubbleScale = max(owner.radius / 20, owner.height / 40);
    mOrigBubbleScale = mBubble.scale * bubbleScale;
    mBubble.floatBobPhase = owner.FloatBobPhase;
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

  private bool isValid(WorldEvent event)
  {
    return !(event.thing == NULL || event.thing is "PlayerPawn");
  }

  private void inflate(Actor died)
  {
    let pos       = died.pos + (0, 0, 10);
    let pretender = Actor.Spawn(died.getClass(), pos);
    pretender.giveInventory(MAGIC, 1);
    let magic     = be_Magic(pretender.findInventory(MAGIC));
    magic.init(pretender, died);
  }

  private void deflate(Actor died)
  {

  }

  const MAGIC = "be_Magic";

} // class be_EventHandler
