<!-- <%= header %> -->
# Project Rules

## Denied Files

DO NOT read, write, or access the following files/directories:

<%= denied_files %>

## Denied Commands

DO NOT execute the following commands:

<%= denied_commands %>

## Allowed Commands

ONLY these commands are permitted for execution:

<%= allowed_commands %>

Any command not in the allowed list above should be avoided unless the user explicitly requests it.

## Global Conventions

<%= conventions %>

## Available Agents

<%= available_agents %>

## Automated Agents

These agents run automatically and cannot be invoked manually:

<%= automated_agents %>

## Available Workflows

<%= workflows %>
