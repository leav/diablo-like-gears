=begin
==========================================================================
  随机装备生成系统 v1.4
==========================================================================

  By 叶子 SailCat
 
  这个系统是在SailCat的随机武器生成系统的基础上编写而成
  类似《暗黑破坏神》的随机生成装备
  
  4-10-2006 1.0
  －先行体验版
  
  4-11-2006 1.1
  －事件调用失去武器防具时，从最后的一个开始失去
  －修正了生成装备时不会出现同样品质的前缀和后缀的BUG
  －部分参数变动，增加了忽略定量参数
  －避免了某些一时冲动插入本脚本，连数据库都不调一下的行为而导致的错误
  
  4-30-2006 1.2
  －修正Window_Base描绘物品的BUG
  －修正杀死敌人不能获得装备的BUG
  －改写了生成装备ID时的冗余代码
  
  5-19-2006 1.3
  －修正了一个致命BUG
  
  11-29-2006 1.4
  －简化了品质设置
  －增加了装备初始权值的设定
  －删除了检查数据库的代码
  －修正了能否装备判定的BUG
 
--------------------------------------------------------------------------
  随机装备生成系统·核心
--------------------------------------------------------------------------
  本部分是随机装备生成系统的核心，基本不会造成与其它脚本冲突，但缺少“随机装备生
  成系统·接入”的话，不能融合到游戏脚本中。
  
 -----------
  使用前须知
 -----------
  
  －本系统分成两个部分，分别为“随机装备生成系统·核心”和
  “随机装备生成系统·接入”，使用时两个部分都要插入。
  
  －因为本系统对RPG底层数据结构的改动非常大,对RGSS完全不了解者不建议采用本系统。
  
  －强烈推荐下载范例工程，可以有一个更直观的认识。
  
  －虽然比SailCat原来的随机武器生成系统的冲突小了一点，但仍然具有很高的冲突性，
  发生冲突的地方大部分都是在“随机装备生成系统·接入”中。
  
  －请仔细耐心阅读完全部说明，最好能看看范例工程中的数据库是怎样设置的。
  
 -----------
  简要使用步骤
 -----------
 
 1、插入“随机装备生成系统·核心”和“随机装备生成系统·接入”到Main之上
 （根据喜好还可以使用附带的已整合脚本：“得失物品金钱提示”和“装备属性显示”）
 
 2、在数据库中的武器和防具部分设置分散数据用装备、前缀和后缀，
 ID请按 Ctrl+F 搜索“■ 随机武器”和“■ 随机防具”，在那里的常量设定里。
 
 -----------
  深入说明（核心部分）
 -----------
  
  在“随机装备生成系统·接入”中还有一些关于获得和失去武器的说明
  
  1、主要名词解释
  
  1.1 母本：
  
  数据库中原本设定的武器（防具），作为随机生成装备数据的基础
  如果母本的属性里面勾了某个品质（见1.5），它就不会被附加上该种品质的前缀和后缀
  
  1.2 前缀：
  
  数据库中指定ID范围的武器（防具），对随机生成装备的数据进行加成，同时在生成的装
  备名称前面加上前缀名称，在生成的装备的说明后面加上前缀说明。
  
  设定位置：数据库中的武器（防具）中
  
  1.3 后缀
  
  数据库中指定ID范围的武器（防具），对随机生成装备的数据进行加成，同时在生成的装
  备名称前面加上后缀名称，在生成的装备的说明后面加上后缀说明。
  
  设定位置：数据库中的武器（防具）中
  
  1.4 分散数据处理ID
  
  对应数据库中的装备ID，用来作装备数据浮动用。为了避免极品和垃圾相差太远，不建议
  把分散数据处理用装备的数据设置得太夸张。
  
  1.5 品质
  
  每一个前缀和后缀都要选择它的品质，品质决定其出现概率
  
  设定位置：数据库中的系统－属性，同时每一个前缀和后缀都要勾上对应品质
  
  1.6 权值
  
  权值决定了装备的颜色
  生成装备的总权值 = 母本权值 + 所有前缀权值 + 所有后缀权值
  
  权值设置方法（无论母本、前缀、后缀都可设置）
  在装备的说明中加上： \权值[n]
  那么它的权值就为n
  不设置的话，权值默认为0
  范例游戏中有设置权值
  
  1.7 生成一个装备的简要流程（忽略参数和定量）：
  
  取得母本（例如事件－获得武器）
  
    |
  
  装备数据的所有数据代入母本数据
  
    |
    
  －开始前缀处理：
  
  按品质概率随机选取一个品质
  
  在属于这个品质的所有前缀中随机取得一个前缀
  
  ·条件分歧：如果前缀没有勾选“no text”属性
  
    装备的名称前插入前缀的名称
    
    装备的说明后加入前缀的说明
  
  ·分歧结束
  
  装备的动画ID = 前缀的动画ID（如果前缀的动画ID不为空）（只有武器才有动画ID）
  
  装备的自动状态ID = 前缀的自动状态ID（如果前缀的自动状态ID不为空）（只用防具才有自动状态ID）
  
  装备的价格 = 其本身 × 前缀的价格 × 0.01
  
  ·条件分歧：如果前缀勾选了“套用基准值”属性
  
    装备的其余各项数字类数据（自动状态ID除外） = 其本身 + 前缀对应数据数字 × 母本基准值 × 0.01
    
    （例外：防具的回避修正忽略基准值，以100代替）
  
  ·除此以外的情况
    
    装备的其余各项数字类数据（自动状态ID除外） = 其本身 × 前缀对应数据数字 × 0.01
  
  ·分歧结束
  
  装备的属性（武器）、防御属性（防具）、附加状态（武器）、解除状态（武器）、
  防御状态（防具） 为其本身与前缀的相同项目的并集（也就是加上前缀的属性、状态等）
  
    |

  －开始后缀处理（除了把名称插在后面之外，其余同前缀）
  
    |
  
  －开始分散数据处理（按照设定的分散数据处理次数重复处理）：
  
  按概率从分散数据处理ID中随机选出一个ID，取得数据库中ID对应的分散数据处理用装备
  
  装备的价格 = 其本身 × 分散数据处理用装备的价格 × 0.01
  
  ·条件分歧：如果分散数据处理用装备勾选了“套用基准值”属性
  
    装备的其余各项数字类数据（自动状态ID除外） = 其本身 + 分散数据处理用装备对应数据数字 × 母本基准值 × 0.01
    
    （例外：防具的回避修正忽略基准值，以100代替）
  
  ·除此以外的情况
    
    装备的其余各项数字类数据（自动状态ID除外） = 其本身 × 分散数据处理用装备对应数据数字 × 0.01
  
  ·分歧结束
  
  装备的属性（武器）、防御属性（防具）、附加状态（武器）、解除状态（武器）、
  防御状态（防具） 为其本身与分散数据处理用装备的相同项目的并集
  （也就是加上分散数据处理用装备的属性、状态等）
  
    |
  
  －开始数据取整
  
    |
  
  －装备生成完毕
  
  简单来说，进行加成就是以新数据（前缀或后缀）乘以旧数据（母本）除以100，同时将
  新数据的各项属性和状态套入旧属性。
  
  一般的话，一个没有勾选“套用基准值”属性的前缀或后缀，其各项数字类数据都是100
  或接近于100，作为加成的百分比。如果勾选了“套用基准值”，除了要加成的项目，各
  项数字都是0。
  
  1.8 基准值：
  
  如果前缀（后缀）勾选了“套用基准值”属性的话，用基准值来代替装备的数据进行加成
  
  例如铜剑防御力为0，但有一个前缀是给武器加防御的，如果不套用基准值的话：
  生成后装备防御力 = 铜剑防御力（0） × 前缀防御力（例如30） = 0
  套用了基准值的话：
  生成后装备防御力 = 铜剑防御力（0）+ 铜剑基准值（例如100） × 前缀防御力（30） = 30
  
  装备基准值设置方法（只有母本才需要设置基准值）
  在母本装备的说明中加上： \基准值[n] 
  那么它的基准值就为n
  不设置的话，基准值默认为0
  范例游戏的母本设置了基准值
  
  1.9 定量
  
  例如有一个前缀和一个后缀，前缀加自动状态“蓄力”，后缀加自动状态“屏障”
  如果两个都没有设置定量或定量相同的话，生成的装备的自动状态为后缀的“屏障”
  如果前缀设置的定量大于后缀的定量，那么这个装备的自动状态就为“蓄力”
  假设这个母本本身带有自动状态，而它的定量比前后缀的定量都大，那么它附加的自动状
  态就不会改变。
  
  前后缀定量设置方法（无论母本、前缀、后缀都可设置）
  在装备的说明中加上： \定量[n]
  那么它的定量就为n
  不设置的话，定量默认为0
  范例游戏中没有设置定量
  
  1.10 防具的前后缀种类（重要！只有防具才有这个设置）
  
  默认的情况下，防具的前缀和后缀只能附加给相同种类的防具。
  例如某前缀的种类为盾，那么这个前缀就只会在盾中出现。
  如果想让一个前缀（后缀）能适用于不同种类的防具，除了设置几个同名不同种类的前缀
  （后缀）外，还可以为同一个前缀（后缀）增加种类。
  
  前后缀种类设置方法（只有前缀和后缀才有这个设置）
  在前后缀用装备的说明中加上： \种类[n] 
  （n的值  0:盾 1:头部防具 2:身体防具 3:装饰品）
  那么它也成为了第n类防具的前缀（后缀）。
  
  这个控制码可以重复输入。
  例如想让一个前缀能适用于所有防具，可以选择其种类为盾，在其说明中加上：
  \种类[1]\种类[2]\种类[3]
  
  2、下面开始边设置边进行说明：
=end

# 2.1 设置生成装备名称颜色：

#--------------------------------------------------------------------------
# ● 获取名字颜色
# 根据生成装备的总品质权值决定其名字颜色
# rarity：品质权值
#--------------------------------------------------------------------------
def get_random_equipment_name_color(rarity)
  case rarity
  when 0
    # 白
    return Color.new(255,255,255)
  when 1
    # 绿
    return Color.new(124,252,0)
  when 2..3
    # 蓝
    return Color.new(30,144,255)
  when 4..5
    # 紫
    return Color.new(218,122,214)
  when 6..7
    # 橙
    return Color.new(255,140,0)
  when 8..100
    # 金
    return Color.new(255,215,0)
  else
    # 灰
    return Color.new(160,160,160)
  end
end

module RPG
  #==========================================================================
  #-------------------------------------
  # ◎ 武器类
  #-------------------------------------
  #==========================================================================
  
  #--------------
  # 2.2 设置武器各种参数：
  #--------------
  
  #==========================================================================
  # ■ 随机武器
  #==========================================================================
  class Random_Weapon < Weapon
    #--------------------------------------------------------------------------
    # ● 定义常量
    #--------------------------------------------------------------------------
    # 以下的ID均是指数据库编号
    #--------------
    # 分散数据处理
    #--------------
    # 名词解释：分散数据处理的意思是每生成一个装备，对其各项数值进行浮动，从而
    # 使得即使是同名装备，它们的数据也不一样。
    #
    # 分散数据处理ID和出现概率（ID个数不限）
    # 格式：{ID=>概率, ID=>概率, ID=>概率...}
    # 大括号、等号、小于号、逗号都要用半角
    FIRST_PROCESS_ID = {501=>6, 502=>6, 503=>2, 504=>2, 505=>2, 506=>2, 507=>2, 
    508=>2, 509=>2, 510=>2}
    #--------------
    # 前缀
    #--------------
    # 就是在武器名前加上前缀的名称，同时使武器各项数值按照该前缀的数据进行加成
    # 前缀ID（数据库中对应武器ID，例如511..520表示从511到520号武器均为前缀）
    PREFIX_ID = 511..520
    # 每一个前缀记得要勾选品质属性，否则不会生成该前缀
    #--------------
    # 后缀
    #--------------
    # 除了把后缀名称加在武器名后，其余和前缀相同
    # 后缀ID
    SUFFIX_ID = 521..530
    #--------------
    # 品质属性
    #--------------
    # 品质属性ID，出现概率和权值（个数不限）
    # 权值：越高代表该品质越好，武器的总品质权值 = 武器母本、前缀和后缀（如果有的话）品质权值之和
    # 格式：{ID=>概率, ID=>概率, ID=>概率, ...}
    RARITY_ELEMENTS = {201=>3, 202=>5, 203=>5, 204=>3, 205=>1}
    #--------------
    # 套用基准值属性ID
    # 如果前缀或后缀勾选了这个属性，就会套用武器基准值。
    REFERENCE_VALUE_ELEMENT = 199
    #--------------
    # 不加入前后缀及说明属性ID
    # 如果前缀或后缀勾选了这个属性，就不在生成的武器名称中加入这个前缀或后缀的
    # 名称，也不加入前缀或后缀的说明
    NO_TEXT_ELEMENT = 200
    #--------------
    # 默认分散数据处理次数
    VARY_DATA_TIMES = 5
    
    
    # 设置防具参数基本同设置武器参数，请按Ctrl+F搜索“防具类”，在那里设置防具参
    # 数
    
    # 下面的prefix_rarity、parameter等参数比较复杂，不要求看懂。它们可以提供更丰
    # 富的扩展性。使用它们的话，需要具有基础RGSS知识。
    
    #--------------------------------------------------------------------------
    # ● 定义实例变量
    #--------------------------------------------------------------------------
    attr_accessor :type                 # 母本ID
    attr_accessor :reference_value      # 基准值，数据加成时用
    attr_accessor :rarity               # 总品质权值
    attr_accessor :reqlevel             # 需求等级（暂时没有实际作用）
    #--------------------------------------------------------------------------
    # ● 初始化对像
    # id : 母本ID（数据库中ID）
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
    def initialize(id, prefix_rarity=[], suffix_rarity=[], parameter=0, prefix_id=0, suffix_id=0)
      # 初始化数据
      @type = id
      @name = $data_weapons[id, true].name
      @icon_name = $data_weapons[id, true].icon_name
      @description = $data_weapons[id, true].description
      @reference_value = $data_weapons[id, true].reference_value
      @current_rating = $data_weapons[id, true].rating
      @animation1_id = $data_weapons[id, true].animation1_id
      @animation2_id = $data_weapons[id, true].animation2_id
      @price = $data_weapons[id, true].price
      @atk = $data_weapons[id, true].atk
      @pdef = $data_weapons[id, true].pdef
      @mdef = $data_weapons[id, true].mdef
      @str_plus = $data_weapons[id, true].str_plus
      @dex_plus = $data_weapons[id, true].dex_plus
      @agi_plus = $data_weapons[id, true].agi_plus
      @int_plus = $data_weapons[id, true].int_plus
      @element_set = $data_weapons[id, true].element_set
      @plus_state_set = $data_weapons[id, true].plus_state_set
      @minus_state_set = $data_weapons[id, true].minus_state_set
      @rarity = $data_weapons[id, true].rarity
      @reqlevel = 1
      # 随机生成数据处理
      random_data(prefix_rarity, suffix_rarity, parameter, prefix_id, suffix_id)
    end
    #--------------------------------------------------------------------------
    # ● 随机生成数据处理
    #--------------------------------------------------------------------------
    def random_data(prefix_rarity=[], suffix_rarity=[], parameter=0, prefix_id=0, suffix_id=0)
      # 前缀处理
      prefix_process(prefix_rarity, parameter, prefix_id)
      # 后缀处理
      suffix_process(suffix_rarity, parameter, suffix_id)
      # 分散数据处理
      vary_data(VARY_DATA_TIMES, parameter)
      # 数据取整
      integer_parameters
    end
    #--------------------------------------------------------------------------
    # ● 前缀处理
    # rarity_type：品质，0为随机选取，大于0则指定为第rarity_type个品质
    #    （从最左边为1开始）
    # parameter：参数
    # prefix_id：指定前缀ID
    #--------------------------------------------------------------------------
    def prefix_process(rarity_type=[], parameter=0, prefix_id=0)
      # 判断是否不进行前缀处理
      return if parameter & 0b1 == 0b1
      # 指定了品质的情况
      if rarity_type != []
        rarity_id = rarity_type[rand(rarity_type.size)]
      # 按概率随机选出品质的情况
      else
        temp = []
        for id in RARITY_ELEMENTS.keys
          RARITY_ELEMENTS[id].times do
            temp.push(id)
          end
        end
        return if temp == []
        rarity_id = temp[rand(temp.size)]
      end
      # 指定了前缀的情况
      if prefix_id > 0
        id = prefix_id
      # 随机选出品质对应的前缀的情况
      else
        # 如果属性里勾了对应的品质的话就返回（除了指定了前后缀以外）
        return if $data_weapons[@type, true].element_set.include?(rarity_id)
        temp = []
        for i in PREFIX_ID
          if $data_weapons[i, true].element_set.include?(rarity_id)
            temp.push(i)
          end
        end
        return if temp == []
        id = temp[rand(temp.size)]
      end
      # 文字及动画ID处理
      text_process(id, parameter, 1)
      # 数据处理
      number_process(id, rarity_id)
    end
    #--------------------------------------------------------------------------
    # ● 后缀处理
    # rarity_type：品质，0为随机选取，大于0则指定为第rarity_type个品质
    #    （从最左边为1开始）
    # parameter：参数
    # suffix_id：指定后缀ID
    #--------------------------------------------------------------------------
    def suffix_process(rarity_type=0, parameter=0, suffix_id=0)
      # 判断是否不进行后缀处理
      return if parameter & 0b10 == 0b10
      # 指定了品质的情况
      if rarity_type != []
        rarity_id = rarity_type[rand(rarity_type.size)]
      # 按概率随机选出品质的情况
      else
        temp = []
        for id in RARITY_ELEMENTS.keys
          RARITY_ELEMENTS[id].times do
            temp.push(id)
          end
        end
        return if temp == []
        rarity_id = temp[rand(temp.size)]
      end
      # 指定了后缀的情况
      if suffix_id > 0
        id = suffix_id
      # 随机选出品质对应的后缀的情况
      else
        # 如果属性里勾了对应的品质的话就返回（除了指定了前后缀以外）
        return if $data_weapons[@type, true].element_set.include?(rarity_id)
        temp = []
        for i in SUFFIX_ID
          if $data_weapons[i, true].element_set.include?(rarity_id)
            temp.push(i)
          end
        end
        return if temp == []
        id = temp[rand(temp.size)]
      end
      # 文字及动画ID处理
      text_process(id, parameter, 2)
      # 数据处理
      number_process(id, rarity_id)
    end
    #--------------------------------------------------------------------------
    # ● 文字及动画ID处理
    # fix：1为前缀，2为后缀
    #--------------------------------------------------------------------------
    def text_process(id, parameter=0, fix=0)
      # 名称和动画处理
      # 判断是否加入前后缀及说明
      if !$data_weapons[id, true].element_set.include?(NO_TEXT_ELEMENT)
        case fix
        when 1
          # 判断是否带前缀名称
          if parameter & 0b100 != 0b100
            @name = $data_weapons[id, true].name + @name 
          end
        when 2
          # 判断是否带后缀名称
          if parameter & 0b1000 != 0b1000
            @name = @name + $data_weapons[id, true].name
          end
        end
        @description = @description + $data_weapons[id, true].description
      end
      if $data_weapons[@type, true].rating >= @current_rating or (parameter & 0b100000 == 0b100000)
        @icon_name = $data_weapons[id, true].icon_name if $data_weapons[id, true].icon_name != ''
        @animation1_id = $data_weapons[id, true].animation1_id if $data_weapons[id, true].animation1_id != 0
        @animation2_id = $data_weapons[id, true].animation2_id if $data_weapons[id, true].animation2_id != 0
        @current_rating = $data_weapons[@type, true].rating
      end
    end
    #--------------------------------------------------------------------------
    # ● 数字类数据处理
    #--------------------------------------------------------------------------
    def number_process(id, rarity_id = 0)
      # 判断是否套用基准值
      if $data_weapons[id, true].element_set.include?(REFERENCE_VALUE_ELEMENT)
        @price = @price * $data_weapons[id, true].price * 0.01
        @atk += @reference_value * $data_weapons[id, true].atk * 0.01
        @pdef += @reference_value * $data_weapons[id, true].pdef * 0.01
        @mdef += @reference_value * $data_weapons[id, true].mdef * 0.01
        @str_plus += @reference_value * $data_weapons[id, true].str_plus * 0.01
        @dex_plus += @reference_value * $data_weapons[id, true].dex_plus * 0.01
        @agi_plus += @reference_value * $data_weapons[id, true].agi_plus * 0.01
        @int_plus += @reference_value * $data_weapons[id, true].int_plus * 0.01
      else
        @price = @price * $data_weapons[id, true].price * 0.01
        @atk = @atk * $data_weapons[id, true].atk * 0.01
        @pdef = @pdef * $data_weapons[id, true].pdef * 0.01
        @mdef = @mdef * $data_weapons[id, true].mdef * 0.01
        @str_plus = @str_plus * $data_weapons[id, true].str_plus * 0.01
        @dex_plus = @dex_plus * $data_weapons[id, true].dex_plus * 0.01
        @agi_plus = @agi_plus * $data_weapons[id, true].agi_plus * 0.01
        @int_plus = @int_plus * $data_weapons[id, true].int_plus * 0.01
      end
      @element_set = ($data_weapons[id, true].element_set | @element_set) -
      [REFERENCE_VALUE_ELEMENT, NO_TEXT_ELEMENT] - RARITY_ELEMENTS.keys
      @plus_state_set = $data_weapons[id, true].plus_state_set | @plus_state_set
      @minus_state_set = $data_weapons[id, true].minus_state_set | @minus_state_set
      @rarity += $data_weapons[id, true].rarity
    end
    #--------------------------------------------------------------------------
    # ● 分散数据处理
    # times：处理次数
    # parameter：参数
    #--------------------------------------------------------------------------
    def vary_data(times=VARY_DATA_TIMES, parameter=0)
      # 判断是否不进行第一数据处理
      return if parameter & 0b10000 == 0b10000
      # 处理times次
      times.times do
        # 按概率随机选出ID
        temp = []
        for id in FIRST_PROCESS_ID.keys
          FIRST_PROCESS_ID[id].times do
            temp.push(id)
          end
        end
        return if temp == []
        id = temp[rand(temp.size)]
        # 数据处理
        number_process(id)
      end
    end
    #--------------------------------------------------------------------------
    # ● 数据取整
    #--------------------------------------------------------------------------
    def integer_parameters
      @price = @price.round
      @atk = @atk.round
      @pdef = @pdef.round
      @mdef = @mdef.round
      @str_plus = @str_plus.round
      @dex_plus = @dex_plus.round
      @agi_plus = @agi_plus.round
      @int_plus = @int_plus.round
    end
    #--------------------------------------------------------------------------
    # ● 定义名字颜色
    #--------------------------------------------------------------------------
    def name_color
      return get_random_equipment_name_color(@rarity)
    end
  end
  #==========================================================================
  # ■ 武器
  #==========================================================================
  class Weapon
    #--------------------------------------------------------------------------
    # ● 定义实例变量
    #--------------------------------------------------------------------------
    attr_accessor :reference_value # 基准值
    attr_accessor :rating          # 定量
    attr_accessor :rarity          # 权值
    #--------------------------------------------------------------------------
    # ● 刷新
    #--------------------------------------------------------------------------
    def refresh
      @description.slice!(/\\基准值\[([0-9]+)\]/)
      @reference_value = $1.to_i
      @description.slice!(/\\定量\[([0-9]+)\]/)
      @rating = $1.to_i
      @description.slice!(/\\权值\[(-*[0-9]+)\]/)
      @rarity = $1.to_i
    end
  end

  #==========================================================================
  #-------------------------------------
  # ◎ 防具类
  #-------------------------------------
  #==========================================================================
  
  #==========================================================================
  # ■ 随机防具
  #==========================================================================
  class Random_Armor < Armor
    #--------------------------------------------------------------------------
    # ● 定义常量
    #--------------------------------------------------------------------------
    # 以下的ID均是指数据库编号
    #--------------
    # 分散数据处理ID和出现概率（个数不限）
    # 格式：{ID=>概率, ID=>概率, ID=>概率...}
    # 大括号、等号、小于号、逗号都要用半角
    FIRST_PROCESS_ID = {497=>6, 498=>6, 499=>6, 500=>6, 501=>6, 502=>6, 503=>2,
    504=>2, 505=>2, 506=>2, 507=>2, 508=>2, 509=>2, 510=>2}
    #--------------
    # 前缀ID
    PREFIX_ID = 511..529
    #--------------
    # 后缀ID
    SUFFIX_ID = 531..544
    #--------------
    # 品质属性ID，出现概率和权值（个数不限）
    # 权值：越高代表该品质越好，暂时没有实际作用
    # 格式：{ID=>概率, ID=>概率, ID=>概率, ...}
    RARITY_ELEMENTS = {201=>3, 202=>5, 203=>5, 204=>3, 205=>1}
    #--------------
    # 套用基准值属性ID
    REFERENCE_VALUE_ELEMENT = 199
    #--------------
    # 不加入前后缀及说明属性ID
    NO_TEXT_ELEMENT = 200
    #--------------
    # 默认分散数据处理次数
    VARY_DATA_TIMES = 5
    #--------------------------------------------------------------------------
    # ● 定义名字颜色
    #--------------------------------------------------------------------------
    def name_color
      return get_random_equipment_name_color(@rarity)
      case @rarity
      when 1
        # 绿
        return Color.new(124,252,0)
      when 2..3
        # 蓝
        return Color.new(30,144,255)
      when 4
        # 紫
        return Color.new(218,122,214)
      when 6..7
        # 橙
        return Color.new(255,140,0)
      when 8..40
        # 金
        return Color.new(255,215,0)
      else
        # 白
        return Color.new(255,255,255)
      end
    end
    #--------------------------------------------------------------------------
    # ● 定义实例变量
    #--------------------------------------------------------------------------
    attr_accessor :type      # 母本ID
    attr_accessor :reference_value      # 基准值，数据加成时用
    attr_accessor :rarity    # 总品质权值
    attr_accessor :reqlevel  # 需求等级（暂时没有实际作用）
    #--------------------------------------------------------------------------
    # ● 初始化对像
    # id : 母本ID（数据库中ID）
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
    #--------------------------------------------------------------------------
    def initialize(id, prefix_rarity=[], suffix_rarity=[], parameter=0, prefix_id=0, suffix_id=0)
      @type = id
      @name = $data_armors[id, true].name
      @icon_name = $data_armors[id, true].icon_name
      @description = $data_armors[id, true].description
      @reference_value = $data_armors[id, true].reference_value
      @current_rating = $data_armors[id, true].rating
      @kind = $data_armors[id, true].kind
      @auto_state_id = $data_armors[id, true].auto_state_id
      @price = $data_armors[id, true].price
      @pdef = $data_armors[id, true].pdef
      @mdef = $data_armors[id, true].mdef
      @eva = $data_armors[id, true].eva
      @str_plus = $data_armors[id, true].str_plus
      @dex_plus = $data_armors[id, true].dex_plus
      @agi_plus = $data_armors[id, true].agi_plus
      @int_plus = $data_armors[id, true].int_plus
      @guard_element_set = $data_armors[id, true].guard_element_set
      @guard_state_set = $data_armors[id, true].guard_state_set
      @rarity = $data_armors[id, true].rarity
      @reqlevel = 1
      # 随机生成数据处理
      random_data(prefix_rarity, suffix_rarity, parameter, prefix_id, suffix_id)
    end
    #--------------------------------------------------------------------------
    # ● 随机生成数据处理
    #--------------------------------------------------------------------------
    def random_data(prefix_rarity=[], suffix_rarity=[], parameter=0, prefix_id=0, suffix_id=0)
      # 前缀处理
      prefix_process(prefix_rarity, parameter, prefix_id)
      # 后缀处理
      suffix_process(suffix_rarity, parameter, suffix_id)
      # 分散数据处理
      vary_data(VARY_DATA_TIMES, parameter)
      # 数据取整
      integer_parameters
    end
    #--------------------------------------------------------------------------
    # ● 前缀处理
    # rarity_type：品质，0为随机选取，大于0则指定为第rarity_type个品质
    #    （从最左边为1开始）
    # parameter：参数
    # prefix_id：指定前缀ID
    #--------------------------------------------------------------------------
    def prefix_process(rarity_type=[], parameter=0, prefix_id=0)
      # 判断是否不进行前缀处理
      return if parameter & 0b1 == 0b1
      # 指定了品质的情况
      if rarity_type != []
        rarity_id = rarity_type[rand(rarity_type.size)]
      # 按概率随机选出品质的情况
      else
        temp = []
        for id in RARITY_ELEMENTS.keys
          RARITY_ELEMENTS[id].times do
            temp.push(id)
          end
        end
        return if temp == []
        rarity_id = temp[rand(temp.size)]
      end
      # 指定了前缀的情况
      if prefix_id > 0
        id = prefix_id
      # 随机选出品质对应的前缀的情况
      else
        # 如果属性里勾了对应的品质的话就返回（除了指定了前后缀以外）
        return if @guard_element_set.include?(rarity_id)
        temp = []
        for i in PREFIX_ID
          if $data_armors[i, true].guard_element_set.include?(rarity_id) and
            $data_armors[i, true].kinds.include?(@kind)
            temp.push(i)
          end
        end
        return if temp == []
        id = temp[rand(temp.size)]
      end
      # 文字、动画、图标和自动状态处理
      text_process(id, parameter, 1)
      # 数据处理
      number_process(id, rarity_id)
    end
    #--------------------------------------------------------------------------
    # ● 后缀处理
    # rarity_type：品质，0为随机选取，大于0则指定为第rarity_type个品质
    #    （从最左边为1开始）
    # parameter：参数
    # suffix_id：指定后缀ID
    #--------------------------------------------------------------------------
    def suffix_process(rarity_type=0, parameter=0, suffix_id=0)
      # 判断是否不进行后缀处理
      return if parameter & 0b10 == 0b10
      # 指定了品质的情况
      if rarity_type != []
        rarity_id = rarity_type[rand(rarity_type.size)]
      # 按概率随机选出品质的情况
      else
        temp = []
        for id in RARITY_ELEMENTS.keys
          RARITY_ELEMENTS[id].times do
            temp.push(id)
          end
        end
        return if temp == []
        rarity_id = temp[rand(temp.size)]
      end
      # 指定了后缀的情况
      if suffix_id > 0
        id = suffix_id
      # 随机选出品质对应的后缀的情况
      else
        # 如果属性里勾了对应的品质的话就返回（除了指定了前后缀以外）
        return if @guard_element_set.include?(rarity_id)
        temp = []
        for i in SUFFIX_ID
          if $data_armors[i, true].guard_element_set.include?(rarity_id) and
            $data_armors[i, true].kinds.include?(@kind)
            temp.push(i)
          end
        end
        return if temp == []
        id = temp[rand(temp.size)]
      end
      # 文字、动画、图标和自动状态处理
      text_process(id, parameter, 2)
      # 数据处理
      number_process(id, rarity_id)
    end
    #--------------------------------------------------------------------------
    # ● 文字、动画、图标和自动状态处理
    # fix：1为前缀，2为后缀
    #--------------------------------------------------------------------------
    def text_process(id, parameter=0, fix=0)
      # 名称和动画处理
      # 判断是否加入前后缀及说明
      if !$data_armors[id, true].guard_element_set.include?(NO_TEXT_ELEMENT)
        case fix
        when 1
          # 判断是否带前缀名称
          if parameter & 0b100 != 0b100
            @name = $data_armors[id, true].name + @name 
          end
        when 2
          # 判断是否带后缀名称
          if parameter & 0b1000 != 0b1000
            @name = @name + $data_armors[id, true].name
          end
        end
        @description = @description + $data_armors[id, true].description
      end
      if $data_armors[@type, true].rating >= @current_rating or (parameter & 0b100000 == 0b100000)
        @icon_name = $data_armors[id, true].icon_name if $data_armors[id, true].icon_name != ''
        @auto_state_id = $data_armors[id, true].auto_state_id if $data_armors[id, true].auto_state_id != 0
        @current_rating = $data_armors[id, true].rating
      end
    end
    #--------------------------------------------------------------------------
    # ● 数字类数据处理
    #--------------------------------------------------------------------------
    def number_process(id, rarity_id = 0)
      # 判断是否套用基准值
      if $data_armors[id, true].guard_element_set.include?(REFERENCE_VALUE_ELEMENT)
        @price = @price * $data_armors[id, true].price * 0.01
        @pdef += @reference_value * $data_armors[id, true].pdef * 0.01
        @mdef += @reference_value * $data_armors[id, true].mdef * 0.01
        @eva += 100 * $data_armors[id, true].eva * 0.01
        @str_plus += @reference_value * $data_armors[id, true].str_plus * 0.01
        @dex_plus += @reference_value * $data_armors[id, true].dex_plus * 0.01
        @agi_plus += @reference_value * $data_armors[id, true].agi_plus * 0.01
        @int_plus += @reference_value * $data_armors[id, true].int_plus * 0.01
      else
        @price = @price * $data_armors[id, true].price * 0.01
        @pdef = @pdef * $data_armors[id, true].pdef * 0.01
        @mdef = @mdef * $data_armors[id, true].mdef * 0.01
        @eva = @eva * $data_armors[id, true].eva * 0.01
        @str_plus = @str_plus * $data_armors[id, true].str_plus * 0.01
        @dex_plus = @dex_plus * $data_armors[id, true].dex_plus * 0.01
        @agi_plus = @agi_plus * $data_armors[id, true].agi_plus * 0.01
        @int_plus = @int_plus * $data_armors[id, true].int_plus * 0.01
      end
      @guard_element_set = ($data_armors[id, true].guard_element_set | @guard_element_set) -
      [REFERENCE_VALUE_ELEMENT, NO_TEXT_ELEMENT] - RARITY_ELEMENTS.keys
      @guard_state_set = $data_armors[id, true].guard_state_set | @guard_state_set
      @rarity += $data_armors[id, true].rarity
    end
    #--------------------------------------------------------------------------
    # ● 分散数据处理
    # times：处理次数
    # parameter：参数
    #--------------------------------------------------------------------------
    def vary_data(times=VARY_DATA_TIMES, parameter=0)
      # 判断是否不进行第一数据处理
      return if parameter & 0b10000 == 0b10000
      # 处理times次
      times.times do
        # 按概率随机选出ID
        temp = []
        for id in FIRST_PROCESS_ID.keys
          FIRST_PROCESS_ID[id].times do
            temp.push(id)
          end
        end
        return if temp == []
        id = temp[rand(temp.size)]
        # 数据处理
        number_process(id)
      end
    end
    #--------------------------------------------------------------------------
    # ● 数据取整
    #--------------------------------------------------------------------------
    def integer_parameters
      @price = @price.round
      @pdef = @pdef.round
      @mdef = @mdef.round
      @eva = @eva.round
      @str_plus = @str_plus.round
      @dex_plus = @dex_plus.round
      @agi_plus = @agi_plus.round
      @int_plus = @int_plus.round
    end
  end
  
  #==========================================================================
  # ■ 防具
  #==========================================================================
  class Armor
    #--------------------------------------------------------------------------
    # ● 定义实例变量
    #--------------------------------------------------------------------------
    attr_accessor :reference_value # 基准值
    attr_accessor :rating          # 定量
    attr_accessor :rarity          # 权值
    attr_accessor :kinds           # 附加种类
    #--------------------------------------------------------------------------
    # ● 刷新
    #--------------------------------------------------------------------------
    def refresh
      @description.slice!(/\\基准值\[([0-9]+)\]/)
      @reference_value = $1.to_i
      @description.slice!(/\\定量\[([0-9]+)\]/)
      @rating = $1.to_i
      @description.slice!(/\\权值\[(-*[0-9]+)\]/)
      @rarity = $1.to_i
      @kinds = [@kind]
      last_kinds = nil
      while last_kinds != @kinds do
        last_kinds = @kinds.clone
        @description.sub!(/\\种类\[([0-9])\]/) { '' }
        @kinds.push($1.to_i) if $1 != nil
      end
    end
  end
end

#==============================================================================
# ■ Game_System
#------------------------------------------------------------------------------
# 　处理系统附属数据的类。也可执行诸如 BGM 管理之类的功能。本类的实例请参考
# $game_system 。
#==============================================================================

class Game_System
  # 装备数据库
  attr_accessor :data_random_weapons
  attr_accessor :data_random_armors
  # 采用Hash保存数据的原因：以后可能会从内存中清除无用物品
  #--------------------------------------------------------------------------
  # ● 创造物品
  # 创造完毕后会返回物品对象ID
  #     type_id : 物品母本ID（数据库ID）
  #     kind    : 种类，1是武器，2是防具
  #--------------------------------------------------------------------------
  def create_item(type_id, kind, prefix_rarity=[], suffix_rarity=[], parameter=0, prefix_id=0, suffix_id=0)
    # 防止出错
    if type_id == 0
      return 0
    end
    case kind
    when 1
      item = RPG::Random_Weapon.new(type_id, prefix_rarity, suffix_rarity, parameter, prefix_id, suffix_id)
      if @data_random_weapons.keys.max.nil?
        id = 1
      else
        id = @data_random_weapons.keys.max + 1
      end
      @data_random_weapons[id] = item
      item.id = id
      return id
    when 2
      item = RPG::Random_Armor.new(type_id, prefix_rarity, suffix_rarity, parameter, prefix_id, suffix_id)
      if @data_random_armors.keys.max.nil?
        id = 1
      else
        id = @data_random_armors.keys.max + 1
      end
      @data_random_armors[id] = item
      item.id = id
      return id
    end
  end
end

#==============================================================================
# ■ Data_Random_Weapons
#------------------------------------------------------------------------------
# 　随机武器数据的类。
#==============================================================================

class Data_Random_Weapons
  def initialize
    @data_weapons       = load_data("Data/Weapons.rxdata")
    # 刷新数据
    for item in @data_weapons
      next if item == nil
      item.refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● parent_data：是否取得母本数据
  #--------------------------------------------------------------------------
  def [](id, parent_data = false)
    if parent_data
      return @data_weapons[id]
    else
      return $game_system.data_random_weapons[id]
    end
  end
  def size
    return $game_system.data_random_weapons.size + @data_weapons.size
  end
end

#==============================================================================
# ■ Data_Random_Armors
#------------------------------------------------------------------------------
# 　随机防具数据的类。
#==============================================================================

class Data_Random_Armors
  def initialize
    @data_armors       = load_data("Data/Armors.rxdata")
    # 刷新数据
    for item in @data_armors
      next if item == nil
      item.refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● parent_data：是否取得母本数据
  #--------------------------------------------------------------------------
  def [](id, parent_data = false)
    if parent_data
      return @data_armors[id]
    else
      return $game_system.data_random_armors[id]
    end
  end
  def size
    return $game_system.data_random_armors.size + @data_armors.size
  end
end