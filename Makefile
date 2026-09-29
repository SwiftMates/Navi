CONFIG := .swift-format
SOURCES := Sources Tests Examples

.PHONY: format lint lint-strict help

help:
	@echo "Available targets:"
	@echo "  make format      - Format all Swift files in-place (Sources, Tests, Examples)"
	@echo "  make lint        - Lint all Swift files (warnings)"
	@echo "  make lint-strict - Lint with strict mode (warnings as errors)"

format:
	swift-format format -i --recursive --configuration $(CONFIG) $(SOURCES)

lint:
	swift-format lint --recursive --configuration $(CONFIG) $(SOURCES)

lint-strict:
	swift-format lint --strict --recursive --configuration $(CONFIG) $(SOURCES)
