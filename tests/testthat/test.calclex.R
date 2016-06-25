#! /usr/bin/env Rscript

library(testthat)
library(rly)

context("calclex")

Lexer <- R6Class("Lexer",
  public = list(
    tokens = c('NAME','NUMBER', 'PLUS','MINUS','TIMES','DIVIDE','EQUALS', 'LPAREN','RPAREN'),
    t_PLUS = '\\+',
    t_MINUS = '-',
    t_TIMES = '\\*',
    t_DIVIDE = '/',
    t_EQUALS = '=',
    t_LPAREN = '\\(',
    t_RPAREN = '\\)',
    t_NAME = '[a-zA-Z_][a-zA-Z0-9_]*',
    t_NUMBER = function(re='\\d+', t) {
      t$value <- strtoi(t$value)
      return(t)
    },
    t_ignore = " \t",
    t_newline = function(re='\n+', t){
      t$lexer$lineno <- t$lexer$lineno + t$value$count("\n")
    },
    t_error = function(t) {
      cat(sprintf("Illegal character '%s'", t$value[1]))
      t$lexer$skip(1)
    }
  )
)

test_that("calclex: +", {
  lexer <- rly::lex(Lexer)
  lexer$input("5 + 3")
  expect_equal(lexer$token()$value, 5)
  expect_equal(lexer$token()$value, "+")
  expect_equal(lexer$token()$value, 3)
})

test_that("calclex: *", {
  lexer <- rly::lex(Lexer)
  lexer$input("x * y")
  expect_equal(lexer$token()$value, "x")
  expect_equal(lexer$token()$value, "*")
  expect_equal(lexer$token()$value, "y")
})

test_that("calclex: without spaces", {
  lexer <- rly::lex(Lexer)
  lexer$input("(x+y)*4")
  expect_equal(lexer$token()$value, "(")
  expect_equal(lexer$token()$value, "x")
  expect_equal(lexer$token()$value, "+")
  expect_equal(lexer$token()$value, "y")
  expect_equal(lexer$token()$value, ")")
  expect_equal(lexer$token()$value, "*")
  expect_equal(lexer$token()$value, 4)
})