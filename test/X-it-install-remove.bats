#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

@test "install remove roundtrip" {
  mkzip "app-a"
  name="app-a"
  instance="prod"
  a="-n $name -i $instance"

  describe "Installing $name/$instance"
  app instance install \
    -r file \
    -u $BATS_TEST_DIRNAME/data/app-a.zip \
    -n $name -i $instance; echo_lines
  [ $status -eq 0 ]

  can_not_read ".app/var/pid/$name-$instance.pid"

  describe "Setting property"
  app -n $name -i $instance conf set env.TEST_PROPERTY awesome
  [ $status -eq 0 ]

  describe "Starting $name/$instance"
  app -n $name -i $instance operate start
  echo_lines
  [ $status -eq 0 ]
  can_read .app/var/pid/$name-$instance.pid

  describe "Stopping $name/$instance"
  app -n $name -i $instance operate stop
  [ $status -eq 0 ]
  echo_lines
  can_not_read .app/var/pid/$name-$instance.pid

  can_read "$name/$instance/logs/$name.log"
  can_read "$name/$instance/logs/$name.env"
  can_read "$name/$instance/current/foo.conf"

  [ "`cat $name/$instance/logs/$name.env`" = "TEST_PROPERTY=awesome" ]
  [ "`cat $name/$instance/current/foo.conf`" = "hello" ]

  # TODO: Remove the version
}