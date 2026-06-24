# frozen_string_literal: true

require 'dotenv'

Dotenv.load(*Dir['.env*'])

require 'minitest/autorun'
require 'securerandom'
require 'tempfile'
require 'open3'
require 'logger'
require 'stringio'
