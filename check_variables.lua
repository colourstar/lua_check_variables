-- 检查所有代码中所有不符合规范的写法

-- version 1.0
-- 1. 解析出变量名
-- 2. 筛选出来被调用者的变量字段,查找o_typedef中的定义
-- 3. 如果不符合条件,那么打印出来

-- version 1.1
-- 增加白名单,为root 和 name进行准备

-- version 1.2
-- 规范化输出格式

-- version 1.3
-- 更新正则表达式

-- version 1.4
-- 更新正则表达式,使其更加符合变量名的要求

-- Author colourstar

-- common require
local lfs = require "lfs"
require "config"
package.path = config_file_path .. '?.lua;' .. package.path
-- global config
-- 检查方式
CONST_CHECK_ALL_FILE = true
CONST_CHECK_FILE_LIST = {
    config_file_path .. config_p .. '/p_main.lua',
}
-- 需要检查的文件
CONST_PROGRAM_PATH = config_file_path .. config_p           -- P层
CONST_COMPONENT_PATH = config_file_path .. config_c         -- C层
CONST_WHITE_LIST_NAME = {'root','name','postfix','showname','id','dbname'}  -- 自带的字段名
CONST_EXCLUDE_TABLE = {'o_node','o_string','o_inst'}                    -- 排除的o表

-- global
g_TypeDefTable = {}             -- 全局所有定义文件
g_OutputFile = nil              -- 结果输出文件
g_CurrentFileName = nil
g_CurrentFuncName = nil

-- check begin
Start_Check = function( )
    if ( CONST_CHECK_ALL_FILE ) then
        _Func_CheckFileDir( CONST_PROGRAM_PATH )
        _Func_CheckFileDir( CONST_COMPONENT_PATH )
    else
        for int_i = 1,#( CONST_CHECK_FILE_LIST ) do
            _Func_CheckFile( CONST_CHECK_FILE_LIST[ int_i ] )
        end
    end
end

-- check file dir
_Func_CheckFileDir = function( filedir )
    for filename in lfs.dir(filedir) do
        if ( _IsValidFilename( filename ) == true ) then
            _Func_CheckFile(filedir .. '/' .. filename)
        end
    end
end

-- check single file
_Func_CheckFile = function( filepath )
    local file = io.open( filepath, 'r' )
    g_CurrentFileName = filepath
    local lineIndex = 0
    for fileline in file:lines() do
        lineIndex = lineIndex + 1
        local fname, args, cmt = string.match(fileline,"function t%.(.+)%((.*)%)(.*)")
        if fname == nil then
            fname, args, cmt = string.match(fileline,"t%['(.+)'%] = function%((.*)%)(.*)")
        end
        if (fname) then
            g_CurrentFuncName = fname
        end

        _Func_CheckFile_FuncContent( filepath, fname, fileline ,lineIndex)
    end
end

-- check file buff
_Func_CheckFile_FuncContent = function( file, func, line ,lineIndex)
    local variable_prefix,variable_name,call_variable = string.match( line, ' o_([^%[%]%.%=%~% ]+)_([^%[%]%.%=%~% ]+)%.([^%[%]%.%=%~% ]+) *[=><~]=*')
    if ( variable_prefix and variable_name and call_variable ) then
        call_variable = _StringTrim( call_variable )
        if ( _IsRTTIValid( 'o_' .. variable_prefix, call_variable ) == false ) then
            if ( g_CurrentFuncName ) then
                g_OutputFile:write( string.format("File:%s Function:%s\n", g_CurrentFileName, g_CurrentFuncName ) )
                g_CurrentFuncName = nil
            end
            g_OutputFile:write( string.format("     Line:%d, TableName:%s, Variable:%s\n", lineIndex,'o_' .. variable_prefix, call_variable ))
        end
    end
end

-- is filename valid ,not . or .. and so on
_IsValidFilename = function( filename )
    if filename == '.' or filename == '..' then
        return false
    end
    if string.sub(filename, 1, 1) == "." then
        return false
    end
    return true
end

Init_Table = function()
    g_OutputFile:write('===================== Init o_typedef =====================\n\n')
    g_TypeDefTable = {}
    local data = require(config_o .. '/o_typedef')
    local table_data = data[2]
    for int_i = 1,#( table_data ) do
        local table_name = table_data[ int_i ][ 'name' ]
        local table_defines = table_data[ int_i ][ 'define' ]
        g_TypeDefTable[ table_name ] = {}

        for int_j = 1,#( table_defines ) do
            local define_table = table_defines[ int_j ]
            local varibale_name = define_table[ 'name' ]
            table.insert( g_TypeDefTable[ table_name ], varibale_name)
        end
    end
end

-- Output File
Init_OutputFile = function()
    g_OutputFile = io.open('unCorrectCall.txt','w')
end

Close_OutputFile = function()
    g_OutputFile:close()
end

_StringTrim = function(s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

-- is o_typedef has the variable
_IsRTTIValid = function( strTableName,strVariable )
    -- white variable list
    for int_i = 1,#( CONST_WHITE_LIST_NAME ) do
        if ( strVariable == CONST_WHITE_LIST_NAME[ int_i ]) then
            return true
        end
    end

    -- white o_table list
    for int_i = 1,#( CONST_EXCLUDE_TABLE) do
        if ( strTableName == CONST_EXCLUDE_TABLE[ int_i ]) then
            return true
        end
    end

    if ( g_TypeDefTable[ strTableName ] == nil ) then
        return false
    end

    for int_i = 1,#( g_TypeDefTable[ strTableName ] ) do
        local table_definename = g_TypeDefTable[ strTableName ][ int_i ]
        if ( table_definename == strVariable ) then
            return true
        end
    end
    return false
end

-- boot
Init_OutputFile()           -- 开启输出文件
Init_Table()                -- 初始化 o_typedef
Start_Check()               -- 开启检查
Close_OutputFile()          -- 关闭输出文件