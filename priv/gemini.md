<!-- <%= header %> -->
# Project Security Rules

## Denied Files

DO NOT read, write, or access the following files/directories:

<%= files %>

## Denied Commands

DO NOT execute the following commands:

<%= d_commands %> 

## Allowed Commands

ONLY these commands are permitted for execution:

<%= a_commands %>

Any command not in the allowed list above should be avoided unless the user explicitly requests it.
