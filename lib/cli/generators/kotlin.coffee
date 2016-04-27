#!/usr/bin/env coffee
###
 * Entitas code generation
 *
 * Generate Kotlin stubs for
 * use with libGDX
 *
 * Demo: 
 * https://github.com/darkoverlordofdata/Bosco.ECS
 * https://github.com/darkoverlordofdata/shmupwarz-unity
 *
###
fs = require('fs')
path = require('path')
mkdirp = require('mkdirp')
config = require("#{process.cwd()}/entitas.json")

getType = (arg) ->
  switch arg
    when 'Int'      then 'Int'
    when 'Float'    then 'Float'
    when 'String'   then 'String'
    when 'Boolean'  then 'Boolean'
    else arg+"?"

getDefault = (arg) ->
  switch arg
    when 'Int'      then '0'
    when 'Float'    then '0f'
    when 'String'   then '""'
    when 'Boolean'  then 'false'
    else 'null'
    

params = (args) ->
  s = []
  for arg in args
    name = arg.split(':')[0]
    type = getType(arg.split(':')[1])
    s.push "#{name}:#{type}"
    
  s.join(', ') 
  

module.exports =
#
# generate entity extensions
#
# @return none
#
  run: (flags...) ->

    sb = []
    s0 = []
    ext = {}
    sys = {}
    s1 = ext['Entity'] = []
    s2 = ext['Matcher'] = []
    s3 = ext['World'] = []
    
    sb.push "package #{config.namespace}"
    sb.push "/**"
    sb.push " * Entitas Global Functions for #{config.namespace}"
    sb.push " *"
    sb.push " * do not edit this file"
    sb.push " */"
    
    s0.push "package #{config.namespace}"
    s0.push "/**"
    s0.push " * Entitas Generated Components for #{config.namespace}"
    s0.push " *"
    s0.push " * do not edit this file"
    s0.push " */"
    s0.push ""
    s0.push "import com.darkoverlordofdata.entitas.IComponent"
    s0.push ""
    
    s1.push "package #{config.namespace}"
    s1.push "/**"
    s1.push " * Entitas Generated Entity Extensions for #{config.namespace}"
    s1.push " *"
    s1.push " * do not edit this file"
    s1.push " */"
    s1.push ""
    s1.push "import java.util.*"
    s1.push "import com.darkoverlordofdata.entitas.Entity"
    s1.push ""
    
    s2.push "package #{config.namespace}"
    s2.push "/**"
    s2.push " * Entitas Generated Matcher Extensions for #{config.namespace}"
    s2.push " *"
    s2.push " * do not edit this file"
    s2.push " */"
    s2.push ""
    s2.push "import com.darkoverlordofdata.entitas.Matcher"
    s2.push "import com.darkoverlordofdata.entitas.IMatcher"
    s2.push ""
    
    s3.push "package #{config.namespace}"
    s3.push "/**"
    s3.push " * Entitas Generated Pool Extensions for #{config.namespace}"
    s3.push " *"
    s3.push " * do not edit this file"
    s3.push " */"
    s3.push ""
    s3.push "import com.darkoverlordofdata.entitas.Pool"
    s3.push "import com.darkoverlordofdata.entitas.Entity"
    s3.push "import com.darkoverlordofdata.entitas.Matcher"
    s3.push ""
    

    ###
     * Components Type Definitions
    ###
    for Name, properties of config.components
      name = Name[0].toLowerCase()+Name[1...]
      s0.push ""
      s0.push "class #{Name}Component() : IComponent {"
      if properties is false 
        s0.push "    var active:Boolean = false"
      else
        for p in properties
          name = p.split(':')[0]
          type = getType(p.split(':')[1])
          value = getDefault(p.split(':')[1])
          s0.push "    var #{name}:#{type} = #{value}"
      s0.push "}"
          
      
               
    ###
     * Components List
    ###
    s0.push ""
    s0.push "enum class Component {"
    
    kc = 0
    for Name, properties of config.components
      name = Name[0].toLowerCase()+Name[1...]
      s0.push "    #{Name},"    
    s0.push "    TotalComponents"    
    s0.push "}"
  
    
    for Name, properties of config.components
      name = Name[0].toLowerCase()+Name[1...]
      
      s1.push "/** Entity: #{Name} methods*/"
      s2.push "/** Matcher: #{Name} methods*/"
      
      
      switch properties
        when false
          s1.push ""
          s1.push "val Entity_#{name}Component =  #{Name}Component()"
          s1.push ""
          s1.push "var Entity.is#{Name}:Boolean"
          s1.push "    get() = hasComponent(Component.#{Name}.ordinal)"
          s1.push "    set(value) {"
          s1.push "        if (value != is#{Name})"
          s1.push "            addComponent(Component.#{Name}.ordinal, Entity_#{name}Component)"
          s1.push "        else"
          s1.push "            removeComponent(Component.#{Name}.ordinal)"
          s1.push "    }"
          s1.push ""
          s1.push "fun Entity.to#{Name}(value:Boolean):Entity {"
          s1.push "    is#{Name} = value"
          s1.push "    return this"
          s1.push "}"
          s1.push ""
          
          s2.push "val Matcher.static.#{Name}:IMatcher"
          s2.push "     get() = Matcher.static.allOf(Component.#{Name}.ordinal) "
          s2.push ""
          
        else
          s1.push ""
          s1.push "val Entity_#{name}ComponentPool:MutableList<#{Name}Component> = ArrayList(listOf())"
          s1.push ""
          s1.push "val Entity.#{name}:#{Name}Component"
          s1.push "    get() = getComponent(Component.#{Name}.ordinal) as #{Name}Component"
          s1.push ""
          s1.push "val Entity.has#{Name}:Boolean"
          s1.push "    get() = hasComponent(Component.#{Name}.ordinal)"
          s1.push ""
          s1.push "fun Entity.clear#{Name}ComponentPool() {"
          s1.push "    Entity_#{name}ComponentPool.clear()"
          s1.push "}"
          s1.push ""
          s1.push "fun Entity.add#{Name}(#{params(properties)}):Entity {"
          s1.push "    val component = if (Entity_#{name}ComponentPool.size > 0) Entity_#{name}ComponentPool.last() else #{Name}Component()"
          for p in properties
            s1.push "    component.#{p.split(':')[0]} = #{p.split(':')[0]}"
          s1.push "    addComponent(Component.#{Name}.ordinal, component)"
          s1.push "    return this"
          s1.push "}"
          s1.push ""
          s1.push "fun Entity.replace#{Name}(#{params(properties)}):Entity {"
          s1.push "    val previousComponent = if (has#{Name}) #{name} else null"
          s1.push "    val component = if (Entity_#{name}ComponentPool.size > 0) Entity_#{name}ComponentPool.last() else #{Name}Component()"
          for p in properties
            s1.push "    component.#{p.split(':')[0]} = #{p.split(':')[0]}"
          s1.push "    replaceComponent(Component.#{Name}.ordinal, component)"
          s1.push "    if (previousComponent != null)"
          s1.push "        Entity_#{name}ComponentPool.add(previousComponent)"
          s1.push "    return this"
          s1.push "}"
          s1.push ""
          s1.push "fun Entity.remove#{Name}():Entity {"
          s1.push "    val component = #{name}"
          s1.push "    removeComponent(Component.#{Name}.ordinal)"
          s1.push "    Entity_#{name}ComponentPool.add(component)"
          s1.push "    return this"
          s1.push "}"
          s1.push ""
          
          s2.push "val Matcher.static.#{Name}:IMatcher"
          s2.push "     get() = Matcher.static.allOf(Component.#{Name}.ordinal) "
          s2.push ""
          
    ###
     * Pooled Entities
    ###
    for Name, type of config.entities
        
        s3.push "/** Pool: #{Name} methods*/"
        
        name = Name[0].toLowerCase()+Name[1...];
        properties = config.components[Name]
        if config.components[Name] is false
            s3.push ""
            s3.push "val Pool.#{name}Entity:Entity?"
            s3.push "    get() = getGroup(Matcher.#{Name})?.singleEntity"
            s3.push ""
            s3.push "var Pool.is#{Name}:Boolean"
            s3.push "    get() = #{name}Entity != null"
            s3.push "    set(value) {"
            s3.push "        val entity = #{name}Entity"
            s3.push "        if (value != (entity != null))"
            s3.push "            if (value)"
            s3.push "                createEntity(\"#{Name}\").is#{Name} = true"
            s3.push "            else"
            s3.push "                destroyEntity(entity)"
            s3.push "    }"
            s3.push ""
        else
            s3.push ""
            s3.push "val Pool.#{name}Entity:Entity?"
            s3.push "    get() = getGroup(Matcher.#{Name})?.singleEntity"
            s3.push ""
            s3.push "val Pool.#{name}:#{Name}Component?"
            s3.push "    get() = #{name}Entity?.#{name}"
            s3.push ""
            s3.push "val Pool.has#{Name}:Boolean"
            s3.push "    get() = #{name}Entity != null"
            s3.push ""
            s3.push "fun Pool.set#{Name}(newValue:#{type}):Entity {"
            s3.push "    if (has#{Name}) throw Exception(\"Single Entity Exception: #{Name}\")"
            s3.push "    val entity = createEntity(\"#{Name}\")"
            s3.push "    entity.add#{Name}(newValue)"
            s3.push "    return entity"
            s3.push "}"
            s3.push ""
            s3.push "fun Pool.replace#{Name}(newValue:#{type}):Entity {"
            s3.push "    var entity = #{name}Entity"
            s3.push "    if (entity == null)"
            s3.push "        entity = set#{Name}(newValue)"
            s3.push "    else"
            s3.push "        entity.replace#{Name}(newValue)"
            s3.push "    return entity"
            s3.push ""
            s3.push "}"
            s3.push "fun Pool.remove#{Name}() {"
            s3.push "    destroyEntity(#{name}Entity)"
            s3.push "}"
            s3.push ""
            
               
    # Components - overwrite
    fs.writeFileSync(path.join(process.cwd(), config.src, 
      "GeneratedComponents.kt"), s0.join('\n'))
    
    # Entity Extensions - overwrite
    fs.writeFileSync(path.join(process.cwd(), config.src, 
      "EntityExtensions.kt"), s1.join('\n'))

    # Matcher Extensions - overwrite
    fs.writeFileSync(path.join(process.cwd(), config.src, 
      "MatcherExtensions.kt"), s2.join('\n'))

    # Pool Extensions - overwrite
    fs.writeFileSync(path.join(process.cwd(), config.src, 
      "PoolExtensions.kt"), s3.join('\n'))

    ###
     * Systems Type Definitions
    ###
    for Name, interfaces of config.systems
      name = Name[0].toLowerCase()+Name[1...]
      sy = sys[Name] = []
      sy.push "package #{config.namespace}.systems"
      sy.push ""
      sy.push "/**"
      sy.push " * Entitas Generated Systems for #{config.namespace}"
      sy.push " *"
      sy.push " */"
      sy.push ""
      sy.push "import com.darkoverlordofdata.entitas.ISetPool"
      sy.push "import com.darkoverlordofdata.entitas.IExecuteSystem"
      sy.push "import com.darkoverlordofdata.entitas.IInitializeSystem"
      sy.push "import com.darkoverlordofdata.entitas.IReactiveExecuteSystem"
      sy.push "import com.darkoverlordofdata.entitas.IMultiReactiveSystem"
      sy.push "import com.darkoverlordofdata.entitas.IReactiveSystem"
      sy.push "import com.darkoverlordofdata.entitas.IEnsureComponents"
      sy.push "import com.darkoverlordofdata.entitas.IExcludeComponents"
      sy.push "import com.darkoverlordofdata.entitas.IClearReactiveSystem"
      sy.push "import com.darkoverlordofdata.entitas.Pool"
      sy.push ""
      sy.push "class #{Name}() "
      
      line  = "    : "
      for iface in interfaces
        line += iface + ", "
      
      l = line.lastIndexOf(",")
      line = line[0...l] + " { "
      sy.push line

      for iface in interfaces
        if 'IMultiReactiveSystem' is iface
          sy.push "    override val triggers:Array<TriggerOnEvent>  {"
          sy.push "    }"
          
        if 'IReactiveSystem' is iface
          sy.push "    override val trigger:TriggerOnEvent  {"
          sy.push "    }"
          
        if 'IEnsureComponents' is iface
          sy.push "    override val ensureComponents:IMatcher  {"
          sy.push "    }"
          
        if 'IExcludeComponents' is iface
          sy.push "    override val excludeComponents:IMatcher  {"
          sy.push "    }"
          
        if 'IClearReactiveSystem' is iface
          sy.push "    override val clearAfterExecute:Boolean  {"
          sy.push "    }"
          
        if 'IReactiveExecuteSystem' is iface
          sy.push "    override fun execute(entities:Array<Entity>) {"
          sy.push "    }"
          
        if 'ISetPool' is iface
          sy.push "    override fun setPool(pool: Pool) {"
          sy.push "    }"
        
        if 'IExecuteSystem' is iface
          sy.push "    override fun execute() {"
          sy.push "    }"
          
        if 'IInitializeSystem' is iface
          sy.push "    override fun initialize() {"
          sy.push "    }"

      sy.push "}" 
    sy.push ""

    # Systems - Do Not overwrite
    for Name, sy of sys
      fileName = path.join(process.cwd(), config.src, "systems/#{Name}.kt")
      fs.writeFileSync(fileName, sy.join('\n')) unless fs.existsSync(fileName)
