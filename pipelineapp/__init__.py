"""Módulo para executar o pipeline completo."""

from .etl import extract, load, pipeline, transform

__all__ = ['extract', 'load', 'transform', 'pipeline']
