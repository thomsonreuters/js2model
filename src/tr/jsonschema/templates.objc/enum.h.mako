<%inherit file="base.mako" />
<%namespace name="base" file="base.mako" />
<%block name='code'>
typedef NS_ENUM(NS_Integer, ${enumDef.name} ) {
% for v in enumDef.values:
    ${ v },
% endfor
};
</%block>