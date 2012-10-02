=begin
==========================================================================
  随机装备生成系统 v1.4
==========================================================================

  By 叶子 SailCat
 
  这个系统是在SailCat的随机武器生成系统的基础上编写而成
 
--------------------------------------------------------------------------
  随机装备生成系统·接入
--------------------------------------------------------------------------
  本部分是随机装备生成系统的接入部分，基本上所有可能冲突的地方都是在这里。
  
 -----------
  使用说明（接入部分）
 -----------
 
  －获得装备原理（以武器为例）：
  
  用事件来获得武器的话，都会生成一把新武器，并不会获得以前已经生成过的武器。如果
  用事件来失去武器，就会搜索母本相同的最新的一把武器，找到后就失去。
  
  如果用脚本：
  获得武器：
  $game_party.gain_weapon(weapon_id, n, new)
  参数：
  new：为true时生成新武器，false时获得旧武器（更换装备时调用这个）
  weapon_id：new为true时为母本ID，new为false时为装备ID（同actor.weapon_id）
  n：n把。每把都会重新计算生成。
  
  失去武器：
  $game_party.lose_weapon(weapon_id, n, serch)
  参数：
  serch：为true时搜索母本相同的武器失去，false时为失去指定ID武器
  weapon_id：serch为true时为母本ID，serch为false时为装备ID（同actor.weapon_id）
  n：n把。
  
  由于获得装备的函数跟原来不同，所以可能会跟商店、仓库类脚本冲突。
  
  生成装备时还可以添加一些参数，实现生成普通装备或强行添加前后缀等，
  具体请按Ctrl+F搜索“● 增加武器 (减少)”
=end

#==============================================================================
# ■ Game_System
#------------------------------------------------------------------------------
# 　处理系统附属数据的类。也可执行诸如 BGM 管理之类的功能。本类的实例请参考
# $game_system 。
#==============================================================================
# 初始化装备数据库
#==============================================================================

class Game_System
  attr_accessor :data_random_weapons
  attr_accessor :data_random_armors
  alias sailcat_initialize initialize
  def initialize
    sailcat_initialize
    # 初始化装备数据库，所有随机生成的装备都在此数据库中
    @data_random_weapons = {}
    @data_random_armors = {}
  end
end

#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　处理角色的类。本类在 Game_Actors 类 ($game_actors)
# 的内部使用、Game_Party 类请参考 ($game_party) 。
#==============================================================================
# 生成角色初始装备，装备判定、变更装备修正
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 设置
  #     actor_id : 角色 ID
  #--------------------------------------------------------------------------
  def setup(actor_id)
    actor = $data_actors[actor_id]
    @actor_id = actor_id
    @name = actor.name
    @character_name = actor.character_name
    @character_hue = actor.character_hue
    @battler_name = actor.battler_name
    @battler_hue = actor.battler_hue
    @class_id = actor.class_id
    # 生成装备
    @weapon_id = $game_system.create_item(actor.weapon_id, 1)
    @armor1_id = $game_system.create_item(actor.armor1_id, 2)
    @armor2_id = $game_system.create_item(actor.armor2_id, 2)
    @armor3_id = $game_system.create_item(actor.armor3_id, 2)
    @armor4_id = $game_system.create_item(actor.armor4_id, 2)
    @level = actor.initial_level
    @exp_list = Array.new(101)
    make_exp_list
    @exp = @exp_list[@level]
    @skills = []
    @hp = maxhp
    @sp = maxsp
    @states = []
    @states_turn = {}
    @maxhp_plus = 0
    @maxsp_plus = 0
    @str_plus = 0
    @dex_plus = 0
    @agi_plus = 0
    @int_plus = 0
    # 学会特技
    for i in 1..@level
      for j in $data_classes[@class_id].learnings
        if j.level == i
          learn_skill(j.skill_id)
        end
      end
    end
    # 刷新自动状态
    update_auto_state(nil, $data_armors[@armor1_id])
    update_auto_state(nil, $data_armors[@armor2_id])
    update_auto_state(nil, $data_armors[@armor3_id])
    update_auto_state(nil, $data_armors[@armor4_id])
  end
  #--------------------------------------------------------------------------
  # ● 变更装备
  #     equip_type : 装备类型
  #     id    : 武器 or 防具 ID  (0 为解除装备)
  #--------------------------------------------------------------------------
  def equip(equip_type, id)
    # $game_party.gain_weapon(@weapon_id, 1, false)，增加参数，不生成新装备
    case equip_type
    when 0  # 武器
      if id == 0 or $game_party.weapon_number(id) > 0
        $game_party.gain_weapon(@weapon_id, 1, false)
        @weapon_id = id
        $game_party.lose_weapon(id, 1)
      end
    when 1  # 盾
      if id == 0 or $game_party.armor_number(id) > 0
        update_auto_state($data_armors[@armor1_id], $data_armors[id])
        $game_party.gain_armor(@armor1_id, 1, false)
        @armor1_id = id
        $game_party.lose_armor(id, 1)
      end
    when 2  # 头
      if id == 0 or $game_party.armor_number(id) > 0
        update_auto_state($data_armors[@armor2_id], $data_armors[id])
        $game_party.gain_armor(@armor2_id, 1, false)
        @armor2_id = id
        $game_party.lose_armor(id, 1)
      end
    when 3  # 身体
      if id == 0 or $game_party.armor_number(id) > 0
        update_auto_state($data_armors[@armor3_id], $data_armors[id])
        $game_party.gain_armor(@armor3_id, 1, false)
        @armor3_id = id
        $game_party.lose_armor(id, 1)
      end
    when 4  # 装饰品
      if id == 0 or $game_party.armor_number(id) > 0
        update_auto_state($data_armors[@armor4_id], $data_armors[id])
        $game_party.gain_armor(@armor4_id, 1, false)
        @armor4_id = id
        $game_party.lose_armor(id, 1)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 可以装备判定
  #     item : 物品
  #--------------------------------------------------------------------------
  def equippable?(item)
    # 武器的情况
    if item.is_a?(RPG::Weapon)
      # 包含当前的职业可以装备武器的场合，调用type取得母本ID
      if item.is_a?(RPG::Random_Weapon)
        if $data_classes[@class_id].weapon_set.include?(item.type)
          return true
        end
      elsif $data_classes[@class_id].weapon_set.include?(item.id)
        return true
      end
    end
    # 防具的情况
    if item.is_a?(RPG::Armor)
      # 包含当前的职业可以装备防具的场合，调用type取得母本ID
      if item.is_a?(RPG::Random_Armor)
        if $data_classes[@class_id].armor_set.include?(item.type)
          return true
        end
      elsif $data_classes[@class_id].armor_set.include?(item.id)
        return true
      end
    end
    return false
  end
end

#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　处理同伴的类。包含金钱以及物品的信息。本类的实例
# 请参考 $game_party。
#==============================================================================
# 大幅度修改得失武器
#==============================================================================


class Game_Party
  #--------------------------------------------------------------------------
  # ● 增加武器 (减少)
  #     weapon_id : 武器 ID
  #     n         : 个数
  #     new       : 是否创建新物品
  #
  # 当new为true时可以添加如下参数：
  # prefix_rarity：前缀品质数组，[]为随机选取，其余则在数组中随机选出一个
  # suffix_rarity：后缀品质数组，[]为随机选取，其余则在数组中随机选出一个
  # parameter：随机生成参数，为0为普通生成（带前后缀），为其它数则有不同效果：
  #    把需要的数加起来则为参数（例如不带前缀名称和不生成后缀为 2+4=6）
  #    1：不生成前缀
  #    2：不生成后缀
  #    4：不带前缀名称
  #    8：不带后缀名称
  #    16：不进行分散数据处理
  #    32：忽略定量，强行附加前缀和后缀的自动状态ID、动画ID、物品图标
  # prefix_id：指定前缀ID，强行附加该前缀
  # suffix_id：指定后缀ID，强行附加该后缀
  #
  # 指定ID可以给武器附加上随机生成不会出现的前后缀（没有勾选品质属性的前后缀）
  #--------------------------------------------------------------------------
  def gain_weapon(weapon_id, n, new = true, prefix_rarity=[], suffix_rarity=[],
    parameter=0, prefix_id=0, suffix_id=0)
    return if weapon_id <= 0
    # 增加的话
    if n > 0
      # 创建新物品的话，weapon_id当作母本ID
      if new
        n.times do
          @id = $game_system.create_item(weapon_id, 1, prefix_rarity,
          suffix_rarity, parameter, prefix_id, suffix_id)
          @weapons[@id] = 1
        end
        return @id
      # 直接增加
      else
        @weapons[weapon_id] = 1
      end
    # 减少的话
    elsif new
      n.abs.times do
        for weapon in $game_system.data_random_weapons.values.reverse
          if weapon.type == weapon_id and @weapons[weapon.id] == 1
            @id = weapon.id
            @weapons[weapon.id] = 0
            break
          end
        end
      end
      return @id
    else
      @weapons[weapon_id] = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 增加防具 (减少)
  #     armor_id : 防具 ID
  #     n        : 个数
  #     new       : 是否创建新物品
  #
  # 当new为true时可以添加如下参数：
  # prefix_rarity：前缀品质数组，[]为随机选取，其余则在数组中随机选出一个
  # suffix_rarity：后缀品质数组，[]为随机选取，其余则在数组中随机选出一个
  # parameter：随机生成参数，为0为普通生成（带前后缀），为其它数则有不同效果：
  #    把需要的数加起来则为参数（例如不带前缀名称和不生成后缀为 2+4=6）
  #    1：不生成前缀
  #    2：不生成后缀
  #    4：不带前缀名称
  #    8：不带后缀名称
  #    16：不进行分散数据处理
  #    32：忽略定量，强行附加前缀和后缀的自动状态ID、动画ID、物品图标
  # prefix_id：指定前缀ID，强行附加该前缀
  # suffix_id：指定后缀ID，强行附加该后缀
  #
  # 指定ID可以给防具附加上随机生成不会出现的前后缀（没有勾选品质属性的前后缀）
  #--------------------------------------------------------------------------
  def gain_armor(armor_id, n, new = true, prefix_rarity=[], suffix_rarity=[],
    parameter=0, prefix_id=0, suffix_id=0)
    return if armor_id <= 0
    # 增加的话
    if n > 0
      # 创建新物品的话，armor_id当作母本ID
      if new
        n.times do
          @id = $game_system.create_item(armor_id, 2, prefix_rarity,
          suffix_rarity, parameter, prefix_id, suffix_id)
          @armors[@id] = 1
        end
        return @id
      # 直接增加
      else
        @armors[armor_id] = 1
      end
    # 减少的话
    elsif new
      n.abs.times do
        for armor in $game_system.data_random_armors.values.reverse
          if armor.type == armor_id and @armors[armor.id] == 1
            @id = armor.id
            @armors[armor.id] = 0
            break
          end
        end
      end
      return @id
    else
      @armors[armor_id] = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 减少武器
  #     weapon_id : 武器 ID
  #     n         : 个数
  #     serch     : 为true时搜索同母本物品删除
  #--------------------------------------------------------------------------
  def lose_weapon(weapon_id, n, serch = false)
    # 调用 gain_weapon 的数值逆转
    gain_weapon(weapon_id, -n, serch)
  end
  #--------------------------------------------------------------------------
  # ● 减少防具
  #     armor_id : 防具 ID
  #     n        : 个数
  #--------------------------------------------------------------------------
  def lose_armor(armor_id, n, serch = false)
    # 调用 gain_armor 的数值逆转
    gain_armor(armor_id, -n, serch)
  end
end

#==============================================================================
# ■ Window_EquipItem
#------------------------------------------------------------------------------
# 　装备画面、显示浏览变更装备的候补物品的窗口。
#==============================================================================
# 判定装备可能时取得母本，显示装备名称颜色
#==============================================================================

class Window_EquipItem < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
    # 添加可以装备的武器
    if @equip_type == 0
      weapon_set = $data_classes[@actor.class_id].weapon_set
      for i in 1...$data_weapons.size
        if $game_party.weapon_number(i) > 0 and weapon_set.include?(
          $game_system.data_random_weapons[i].type) # type取得母本
          @data.push($data_weapons[i])
        end
      end
    end
    # 添加可以装备的防具
    if @equip_type != 0
      armor_set = $data_classes[@actor.class_id].armor_set
      for i in 1...$data_armors.size
        if $game_party.armor_number(i) > 0 and armor_set.include?(
          $game_system.data_random_armors[i].type) # type取得母本
          if $data_armors[i].kind == @equip_type-1
            @data.push($data_armors[i])
          end
        end
      end
    end
    # 添加空白
    @data.push(nil)
    # 生成位图、描绘全部项目
    @item_max = @data.size
    self.contents = Bitmap.new(width - 32, row_max * 32)
    for i in 0...@item_max-1
      draw_item(i)
    end
  end
  #--------------------------------------------------------------------------
  # ● 项目的描绘
  #     index : 项目符号
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    x = 4
    y = index * 32
    case item
    when RPG::Weapon
      number = $game_party.weapon_number(item.id)
    when RPG::Armor
      number = $game_party.armor_number(item.id)
    end
    bitmap = RPG::Cache.icon(item.icon_name)
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24))
    # 取得名称颜色
    self.contents.font.color = item.name_color
    self.contents.draw_text(x + 28, y, 212, 32, item.name, 0)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 240, y, 16, 32, ":", 1)
    self.contents.draw_text(x + 256, y, 24, 32, number.to_s, 2)
  end
end

#==============================================================================
# ■ Window_Base
#------------------------------------------------------------------------------
# 　游戏中全部窗口的超级类。
#==============================================================================
# 显示装备颜色
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # ● 描绘物品名
  #     item : 物品
  #     x    : 描画目标 X 坐标
  #     y    : 描画目标 Y 坐标
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y)
    if item == nil
      return
    end
    bitmap = RPG::Cache.icon(item.icon_name)
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24))
    self.contents.font.color = normal_color
    # 取得颜色
    if item.is_a?(RPG::Random_Weapon) or item.is_a?(RPG::Random_Armor)
      self.contents.font.color = item.name_color
    end
    self.contents.draw_text(x + 28, y, 212, 32, item.name)
    self.contents.font.color = normal_color
  end
end

#==============================================================================
# ■ Window_ShopBuy
#------------------------------------------------------------------------------
# 　商店画面、浏览显示可以购买的商品的窗口。
#==============================================================================
# 商店只出售母本
#==============================================================================

class Window_ShopBuy < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 刷新
  #--------------------------------------------------------------------------
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
    for goods_item in @shop_goods
      case goods_item[0]
      when 0
        item = $data_items[goods_item[1]]
      # 取得母本
      when 1
        item = $data_weapons[goods_item[1], true]
      # 取得母本
      when 2
        item = $data_armors[goods_item[1], true]
      end
      if item != nil
        @data.push(item)
      end
    end
    # 如果项目数不是 0 就生成位图、描绘全部项目
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, row_max * 32)
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end
end

#==============================================================================
# ■ Scene_Title
#------------------------------------------------------------------------------
# 　处理标题画面的类。
#==============================================================================
# 绕过原来的$data_weapons和$data_armors
#==============================================================================

class Scene_Title
  #--------------------------------------------------------------------------
  # ● 住处理
  #--------------------------------------------------------------------------
  def main
    # 战斗测试的情况下
    if $BTEST
      battle_test
      return
    end
    # 载入数据库
    $data_actors        = load_data("Data/Actors.rxdata")
    $data_classes       = load_data("Data/Classes.rxdata")
    $data_skills        = load_data("Data/Skills.rxdata")
    $data_items         = load_data("Data/Items.rxdata")
    # 绕过原来的数据库，使得可以同时取得母本和生成的装备
    $data_weapons       = Data_Random_Weapons.new
    $data_armors        = Data_Random_Armors.new
    $data_enemies       = load_data("Data/Enemies.rxdata")
    $data_troops        = load_data("Data/Troops.rxdata")
    $data_states        = load_data("Data/States.rxdata")
    $data_animations    = load_data("Data/Animations.rxdata")
    $data_tilesets      = load_data("Data/Tilesets.rxdata")
    $data_common_events = load_data("Data/CommonEvents.rxdata")
    $data_system        = load_data("Data/System.rxdata")
    # 生成系统对像
    $game_system = Game_System.new
    # 生成标题图形
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.title($data_system.title_name)
    # 生成命令窗口
    s1 = "新游戏"
    s2 = "继续"
    s3 = "退出"
    @command_window = Window_Command.new(192, [s1, s2, s3])
    @command_window.back_opacity = 160
    @command_window.x = 320 - @command_window.width / 2
    @command_window.y = 288
    # 判定继续的有效性
    # 存档文件一个也不存在的时候也调查
    # 有効为 @continue_enabled 为 true、無効为 false
    @continue_enabled = false
    for i in 0..3
      if FileTest.exist?("Save#{i+1}.rxdata")
        @continue_enabled = true
      end
    end
    # 继续为有效的情况下、光标停止在继续上
    # 无效的情况下、继续的文字显示为灰色
    if @continue_enabled
      @command_window.index = 1
    else
      @command_window.disable_item(1)
    end
    # 演奏标题 BGM
    $game_system.bgm_play($data_system.title_bgm)
    # 停止演奏 ME、BGS
    Audio.me_stop
    Audio.bgs_stop
    # 执行过渡
    Graphics.transition
    # 主循环
    loop do
      # 刷新游戏画面
      Graphics.update
      # 刷新输入信息
      Input.update
      # 刷新画面
      update
      # 如果画面被切换就中断循环
      if $scene != self
        break
      end
    end
    # 装备过渡
    Graphics.freeze
    # 释放命令窗口
    @command_window.dispose
    # 释放标题图形
    @sprite.bitmap.dispose
    @sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● 战斗测试
  #--------------------------------------------------------------------------
  def battle_test
    # 载入数据库 (战斗测试用)
    $data_actors        = load_data("Data/BT_Actors.rxdata")
    $data_classes       = load_data("Data/BT_Classes.rxdata")
    $data_skills        = load_data("Data/BT_Skills.rxdata")
    $data_items         = load_data("Data/BT_Items.rxdata")
    # 绕过原来的数据库，使得可以同时取得母本和生成的装备
    $data_weapons       = Data_Random_Weapons.new
    $data_armors        = Data_Random_Armors.new
    $data_enemies       = load_data("Data/BT_Enemies.rxdata")
    $data_troops        = load_data("Data/BT_Troops.rxdata")
    $data_states        = load_data("Data/BT_States.rxdata")
    $data_animations    = load_data("Data/BT_Animations.rxdata")
    $data_tilesets      = load_data("Data/BT_Tilesets.rxdata")
    $data_common_events = load_data("Data/BT_CommonEvents.rxdata")
    $data_system        = load_data("Data/BT_System.rxdata")
    # 重置测量游戏时间用的画面计数器
    Graphics.frame_count = 0
    # 生成各种游戏对像
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    # 设置战斗测试用同伴
    $game_party.setup_battle_test_members
    # 设置队伍 ID、可以逃走标志、战斗背景
    $game_temp.battle_troop_id = $data_system.test_troop_id
    $game_temp.battle_can_escape = true
    $game_map.battleback_name = $data_system.battleback_name
    # 演奏战斗开始 BGM
    $game_system.se_play($data_system.battle_start_se)
    # 演奏战斗 BGM
    $game_system.bgm_play($game_system.battle_bgm)
    # 切换到战斗画面
    $scene = Scene_Battle.new
  end
end


#==============================================================================
# ■ Scene_Battle (分割定义 2)
#------------------------------------------------------------------------------
# 　处理战斗画面的类。
#==============================================================================
# 战斗后获得随机生成物品
#==============================================================================

class Scene_Battle
  #--------------------------------------------------------------------------
  # ● 开始结束战斗回合
  #--------------------------------------------------------------------------
  def start_phase5
    # 转移到回合 5
    @phase = 5
    # 演奏战斗结束 ME
    $game_system.me_play($game_system.battle_end_me)
    # 还原为战斗开始前的 BGM
    $game_system.bgm_play($game_temp.map_bgm)
    # 初始化 EXP、金钱、宝物
    exp = 0
    gold = 0
    treasures = []
    # 循环
    for enemy in $game_troop.enemies
      # 敌人不是隐藏状态的情况下
      unless enemy.hidden
        # 获得 EXP、增加金钱
        exp += enemy.exp
        gold += enemy.gold
        # 出现宝物判定
        if rand(100) < enemy.treasure_prob
          if enemy.item_id > 0
            treasures.push($data_items[enemy.item_id])
          end
          # 生成物品
          if enemy.weapon_id > 0
            treasures.push($data_weapons[$game_system.create_item(enemy.weapon_id, 1)])
          end
          if enemy.armor_id > 0
            treasures.push($data_armors[$game_system.create_item(enemy.armor_id, 1)])
          end
        end
      end
    end
    # 限制宝物数为 6 个
    treasures = treasures[0..5]
    # 获得 EXP
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      if actor.cant_get_exp? == false
        last_level = actor.level
        actor.exp += exp
        if actor.level > last_level
          @status_window.level_up(i)
        end
      end
    end
    # 获得金钱
    $game_party.gain_gold(gold)
    # 获得宝物
    for item in treasures
      case item
      when RPG::Item
        $game_party.gain_item(item.id, 1)
      # 获得已生成物品
      when RPG::Weapon
        $game_party.gain_weapon(item.id, 1, false)
      when RPG::Armor
        $game_party.gain_armor(item.id, 1, false)
      end
    end
    # 生成战斗结果窗口
    @result_window = Window_BattleResult.new(exp, gold, treasures)
    # 设置等待计数
    @phase5_wait_count = 100
  end
end