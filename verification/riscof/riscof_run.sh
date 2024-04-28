envsubst < $RV_ROOT/verification/riscof/config.ini.template > $RV_ROOT/verification/riscof/config.ini
riscof --verbose info arch-test --clone
riscof validateyaml --config=$RV_ROOT/verification/riscof/config.ini
riscof testlist --config=$RV_ROOT/verification/riscof/config.ini --suite=riscv-arch-test/riscv-test-suite/ --env=riscv-arch-test/riscv-test-suite/env
riscof run --config=$RV_ROOT/verification/riscof/config.ini --suite=riscv-arch-test/riscv-test-suite/ --env=riscv-arch-test/riscv-test-suite/env
