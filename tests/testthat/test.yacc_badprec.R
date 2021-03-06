#! /usr/bin/env Rscript

library(testthat)
library(rly)

context("Bad precedence specifier")

Parser <- R6Class("Parser",
  public = list(
    tokens = c('NAME','NUMBER', 'PLUS','MINUS','TIMES','DIVIDE','EQUALS', 'LPAREN','RPAREN'),
    # Parsing rules
    precedence = "blah",
    # dictionary of names
    names = new.env(hash=TRUE),
    p_statement_assign = function(doc='statement : NAME EQUALS expression', p) {
      self$names[[as.character(p$get(2))]] <- p$get(4)
    },
    p_statement_expr = function(doc='statement : expression', p) {
      cat(p$get(2))
      cat('\n')
    },
    p_expression_binop = function(doc='expression : expression PLUS expression
                                                  | expression MINUS expression
                                                  | expression TIMES expression
                                                  | expression DIVIDE expression', t) {
      if(p$get(3) == 'PLUS') p$set(1, p$get(2) + p$get(4))
      else if(p$get(3) == 'MINUS') p$set(1, p$get(2) - p$get(4))
      else if(p$get(3) == 'TIMES') p$set(1, p$get(2) * p$get(4))
      else if(p$get(3) == 'DIVIDE') p$set(1, p$get(2) / p$get(4))
    },
    p_expression_uminus = function(doc='expression : MINUS expression %prec UMINUS', t) {
      p$set(1, -p$get(3))
    },
    p_expression_group = function(doc='expression : LPAREN expression RPAREN', t) {
      p$set(1, p$get(3))
    },
    p_expression_number = function(doc='expression : NUMBER', t) {
      p$set(1, p$get(2))
    },
    p_expression_name = function(doc='expression : NAME', t) {
      p$set(1, self$names[[as.character(p$get(2))]])
    },
    p_error = function(t) {
      cat(sprintf("Syntax error at '%s'", t$value))
    }
  )
)

test_that("precedence", {
  expect_output(expect_error(rly::yacc(Parser), "Unable to build parser"),
  "ERROR .* precedence must be a list")
})
