	.amdgcn_target "amdgcn-amd-amdhsa--gfx1151"
	.amdhsa_code_object_version 6
	.text
	.protected	_Z12matmul_naivePKfS0_Pfi ; -- Begin function _Z12matmul_naivePKfS0_Pfi
	.globl	_Z12matmul_naivePKfS0_Pfi
	.p2align	8
	.type	_Z12matmul_naivePKfS0_Pfi,@function
_Z12matmul_naivePKfS0_Pfi:              ; @_Z12matmul_naivePKfS0_Pfi
; %bb.0:
	s_clause 0x1
	s_load_b32 s4, s[0:1], 0x2c
	s_load_b32 s8, s[0:1], 0x18
	v_bfe_u32 v1, v0, 10, 10
	v_and_b32_e32 v0, 0x3ff, v0
	s_waitcnt lgkmcnt(0)
	s_lshr_b32 s5, s4, 16
	s_and_b32 s4, s4, 0xffff
	v_mad_u64_u32 v[2:3], null, s3, s5, v[1:2]
	v_mad_u64_u32 v[0:1], null, s2, s4, v[0:1]
	s_mov_b32 s2, exec_lo
	v_max_i32_e32 v1, v2, v0
	s_delay_alu instid0(VALU_DEP_1)
	v_cmpx_gt_i32_e64 s8, v1
	s_cbranch_execz .LBB0_6
; %bb.1:
	s_clause 0x1
	s_load_b128 s[4:7], s[0:1], 0x0
	s_load_b64 s[0:1], s[0:1], 0x10
	v_mul_lo_u32 v1, v2, s8
	s_cmp_lt_i32 s8, 1
	s_cbranch_scc1 .LBB0_4
; %bb.2:
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_3) | instid1(VALU_DEP_3)
	v_ashrrev_i32_e32 v2, 31, v1
	v_mov_b32_e32 v6, 0
	v_mov_b32_e32 v4, v0
	s_mov_b32 s2, s8
	v_lshlrev_b64 v[2:3], 2, v[1:2]
	s_waitcnt lgkmcnt(0)
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_add_co_u32 v2, vcc_lo, s4, v2
	v_add_co_ci_u32_e64 v3, null, s5, v3, vcc_lo
	.p2align	6
.LBB0_3:                                ; =>This Inner Loop Header: Depth=1
	v_ashrrev_i32_e32 v5, 31, v4
	s_add_i32 s2, s2, -1
	s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	s_cmp_eq_u32 s2, 0
	v_lshlrev_b64 v[7:8], 2, v[4:5]
	v_add_nc_u32_e32 v4, s8, v4
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_add_co_u32 v7, vcc_lo, s6, v7
	v_add_co_ci_u32_e64 v8, null, s7, v8, vcc_lo
	global_load_b32 v5, v[2:3], off
	global_load_b32 v7, v[7:8], off
	v_add_co_u32 v2, vcc_lo, v2, 4
	s_delay_alu instid0(VALU_DEP_1)
	v_add_co_ci_u32_e64 v3, null, 0, v3, vcc_lo
	s_waitcnt vmcnt(0)
	v_fmac_f32_e32 v6, v5, v7
	s_cbranch_scc0 .LBB0_3
	s_branch .LBB0_5
.LBB0_4:
	v_mov_b32_e32 v6, 0
.LBB0_5:
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_add_nc_u32_e32 v0, v1, v0
	v_ashrrev_i32_e32 v1, 31, v0
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_1) | instid1(VALU_DEP_1)
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	s_waitcnt lgkmcnt(0)
	v_add_co_u32 v0, vcc_lo, s0, v0
	s_delay_alu instid0(VALU_DEP_1)
	v_add_co_ci_u32_e64 v1, null, s1, v1, vcc_lo
	global_store_b32 v[0:1], v6, off
.LBB0_6:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _Z12matmul_naivePKfS0_Pfi
		.amdhsa_group_segment_fixed_size 0
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 288
		.amdhsa_user_sgpr_count 2
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 1
		.amdhsa_next_free_vgpr 9
		.amdhsa_next_free_sgpr 9
		.amdhsa_reserve_vcc 1
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_inst_pref_size 3
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end0:
	.size	_Z12matmul_naivePKfS0_Pfi, .Lfunc_end0-_Z12matmul_naivePKfS0_Pfi
                                        ; -- End function
	.set _Z12matmul_naivePKfS0_Pfi.num_vgpr, 9
	.set _Z12matmul_naivePKfS0_Pfi.num_agpr, 0
	.set _Z12matmul_naivePKfS0_Pfi.numbered_sgpr, 9
	.set _Z12matmul_naivePKfS0_Pfi.private_seg_size, 0
	.set _Z12matmul_naivePKfS0_Pfi.uses_vcc, 1
	.set _Z12matmul_naivePKfS0_Pfi.uses_flat_scratch, 0
	.set _Z12matmul_naivePKfS0_Pfi.has_dyn_sized_stack, 0
	.set _Z12matmul_naivePKfS0_Pfi.has_recursion, 0
	.set _Z12matmul_naivePKfS0_Pfi.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 344
; TotalNumSgprs: 11
; NumVgprs: 9
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 0 bytes/workgroup (compile time only)
; SGPRBlocks: 1
; VGPRBlocks: 1
; NumSGPRsForWavesPerEU: 11
; NumVGPRsForWavesPerEU: 9
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 2
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 1
	.text
	.protected	_Z12matmul_tiledPKfS0_Pfi ; -- Begin function _Z12matmul_tiledPKfS0_Pfi
	.globl	_Z12matmul_tiledPKfS0_Pfi
	.p2align	8
	.type	_Z12matmul_tiledPKfS0_Pfi,@function
_Z12matmul_tiledPKfS0_Pfi:              ; @_Z12matmul_tiledPKfS0_Pfi
; %bb.0:
	s_clause 0x2
	s_load_b32 s10, s[0:1], 0x18
	s_load_b128 s[4:7], s[0:1], 0x0
	s_load_b64 s[8:9], s[0:1], 0x10
	v_bfe_u32 v4, v0, 10, 10
	v_and_b32_e32 v5, 0x3ff, v0
	s_lshl_b32 s1, s2, 4
	s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_2)
	v_lshl_add_u32 v3, s3, 4, v4
	v_add_nc_u32_e32 v0, s1, v5
	s_waitcnt lgkmcnt(0)
	s_cmp_lt_i32 s10, 1
	s_cbranch_scc1 .LBB1_7
; %bb.1:
	v_dual_mov_b32 v6, 0 :: v_dual_lshlrev_b32 v1, 2, v5
	v_mul_lo_u32 v2, v4, s10
	v_lshlrev_b32_e32 v7, 6, v4
	v_mul_lo_u32 v9, s10, v3
	s_delay_alu instid0(VALU_DEP_4)
	v_add_nc_u32_e32 v8, 0x400, v1
	v_cmp_gt_i32_e64 s0, s10, v0
	s_add_i32 s2, s10, 15
	v_add_nc_u32_e32 v10, v7, v1
	s_lshr_b32 s2, s2, 4
	v_add3_u32 v1, v5, v2, s1
	v_add_nc_u32_e32 v11, v8, v7
	s_lshl_b32 s3, s10, 4
	v_cmp_gt_i32_e32 vcc_lo, s10, v3
	s_branch .LBB1_3
.LBB1_2:                                ;   in Loop: Header=BB1_3 Depth=1
	s_or_b32 exec_lo, exec_lo, s11
	s_waitcnt vmcnt(0)
	ds_store_b32 v11, v12
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	ds_load_2addr_b32 v[20:21], v8 offset1:16
	ds_load_b128 v[12:15], v7
	ds_load_2addr_b32 v[22:23], v8 offset0:32 offset1:48
	ds_load_b128 v[16:19], v7 offset:16
	ds_load_2addr_b32 v[24:25], v8 offset0:64 offset1:80
	v_add_nc_u32_e32 v4, 16, v4
	s_add_i32 s2, s2, -1
	v_add_nc_u32_e32 v5, 16, v5
	s_cmp_eq_u32 s2, 0
	s_waitcnt lgkmcnt(3)
	v_dual_fmac_f32 v6, v12, v20 :: v_dual_add_nc_u32 v1, s3, v1
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_3) | instid1(VALU_DEP_1)
	v_fmac_f32_e32 v6, v13, v21
	ds_load_2addr_b32 v[20:21], v8 offset0:96 offset1:112
	s_waitcnt lgkmcnt(3)
	v_fmac_f32_e32 v6, v14, v22
	v_fmac_f32_e32 v6, v15, v23
	ds_load_2addr_b32 v[22:23], v8 offset0:128 offset1:144
	ds_load_b128 v[12:15], v7 offset:32
	s_waitcnt lgkmcnt(3)
	v_fmac_f32_e32 v6, v16, v24
	s_delay_alu instid0(VALU_DEP_1) | instskip(SKIP_3) | instid1(VALU_DEP_1)
	v_fmac_f32_e32 v6, v17, v25
	ds_load_2addr_b32 v[24:25], v8 offset0:160 offset1:176
	s_waitcnt lgkmcnt(3)
	v_fmac_f32_e32 v6, v18, v20
	v_fmac_f32_e32 v6, v19, v21
	ds_load_b128 v[16:19], v7 offset:48
	ds_load_2addr_b32 v[20:21], v8 offset0:192 offset1:208
	s_waitcnt lgkmcnt(3)
	v_fmac_f32_e32 v6, v12, v22
	s_delay_alu instid0(VALU_DEP_1)
	v_fmac_f32_e32 v6, v13, v23
	ds_load_2addr_b32 v[12:13], v8 offset0:224 offset1:240
	s_waitcnt lgkmcnt(0)
	s_barrier
	buffer_gl0_inv
	v_fmac_f32_e32 v6, v14, v24
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_fmac_f32_e32 v6, v15, v25
	v_fmac_f32_e32 v6, v16, v20
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_fmac_f32_e32 v6, v17, v21
	v_fmac_f32_e32 v6, v18, v12
	s_delay_alu instid0(VALU_DEP_1)
	v_fmac_f32_e32 v6, v19, v13
	s_cbranch_scc1 .LBB1_8
.LBB1_3:                                ; =>This Inner Loop Header: Depth=1
	v_cmp_gt_i32_e64 s1, s10, v5
	v_mov_b32_e32 v2, 0
	s_and_b32 s1, vcc_lo, s1
	s_delay_alu instid0(SALU_CYCLE_1)
	s_and_saveexec_b32 s11, s1
	s_cbranch_execz .LBB1_5
; %bb.4:                                ;   in Loop: Header=BB1_3 Depth=1
	v_add_nc_u32_e32 v12, v9, v5
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_ashrrev_i32_e32 v13, 31, v12
	v_lshlrev_b64 v[12:13], 2, v[12:13]
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_add_co_u32 v12, s1, s4, v12
	v_add_co_ci_u32_e64 v13, null, s5, v13, s1
	global_load_b32 v2, v[12:13], off
.LBB1_5:                                ;   in Loop: Header=BB1_3 Depth=1
	s_or_b32 exec_lo, exec_lo, s11
	v_cmp_gt_i32_e64 s1, s10, v4
	v_mov_b32_e32 v12, 0
	s_waitcnt vmcnt(0)
	ds_store_b32 v10, v2
	s_and_b32 s1, s0, s1
	s_delay_alu instid0(SALU_CYCLE_1)
	s_and_saveexec_b32 s11, s1
	s_cbranch_execz .LBB1_2
; %bb.6:                                ;   in Loop: Header=BB1_3 Depth=1
	v_ashrrev_i32_e32 v2, 31, v1
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_lshlrev_b64 v[12:13], 2, v[1:2]
	v_add_co_u32 v12, s1, s6, v12
	s_delay_alu instid0(VALU_DEP_1)
	v_add_co_ci_u32_e64 v13, null, s7, v13, s1
	global_load_b32 v12, v[12:13], off
	s_branch .LBB1_2
.LBB1_7:
	v_mov_b32_e32 v6, 0
.LBB1_8:
	v_max_i32_e32 v1, v3, v0
	s_mov_b32 s0, exec_lo
	s_delay_alu instid0(VALU_DEP_1)
	v_cmpx_gt_i32_e64 s10, v1
	s_cbranch_execz .LBB1_10
; %bb.9:
	v_mad_u64_u32 v[0:1], null, s10, v3, v[0:1]
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_ashrrev_i32_e32 v1, 31, v0
	v_lshlrev_b64 v[0:1], 2, v[0:1]
	s_delay_alu instid0(VALU_DEP_1) | instskip(NEXT) | instid1(VALU_DEP_1)
	v_add_co_u32 v0, vcc_lo, s8, v0
	v_add_co_ci_u32_e64 v1, null, s9, v1, vcc_lo
	global_store_b32 v[0:1], v6, off
.LBB1_10:
	s_endpgm
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel _Z12matmul_tiledPKfS0_Pfi
		.amdhsa_group_segment_fixed_size 2048
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 28
		.amdhsa_user_sgpr_count 2
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_wavefront_size32 1
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 0
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 1
		.amdhsa_next_free_vgpr 26
		.amdhsa_next_free_sgpr 12
		.amdhsa_reserve_vcc 1
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_workgroup_processor_mode 1
		.amdhsa_memory_ordered 1
		.amdhsa_forward_progress 1
		.amdhsa_shared_vgpr_count 0
		.amdhsa_inst_pref_size 6
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text
.Lfunc_end1:
	.size	_Z12matmul_tiledPKfS0_Pfi, .Lfunc_end1-_Z12matmul_tiledPKfS0_Pfi
                                        ; -- End function
	.set _Z12matmul_tiledPKfS0_Pfi.num_vgpr, 26
	.set _Z12matmul_tiledPKfS0_Pfi.num_agpr, 0
	.set _Z12matmul_tiledPKfS0_Pfi.numbered_sgpr, 12
	.set _Z12matmul_tiledPKfS0_Pfi.private_seg_size, 0
	.set _Z12matmul_tiledPKfS0_Pfi.uses_vcc, 1
	.set _Z12matmul_tiledPKfS0_Pfi.uses_flat_scratch, 0
	.set _Z12matmul_tiledPKfS0_Pfi.has_dyn_sized_stack, 0
	.set _Z12matmul_tiledPKfS0_Pfi.has_recursion, 0
	.set _Z12matmul_tiledPKfS0_Pfi.has_indirect_call, 0
	.section	.AMDGPU.csdata,"",@progbits
; Kernel info:
; codeLenInByte = 688
; TotalNumSgprs: 14
; NumVgprs: 26
; ScratchSize: 0
; MemoryBound: 0
; FloatMode: 240
; IeeeMode: 1
; LDSByteSize: 2048 bytes/workgroup (compile time only)
; SGPRBlocks: 1
; VGPRBlocks: 3
; NumSGPRsForWavesPerEU: 14
; NumVGPRsForWavesPerEU: 26
; Occupancy: 16
; WaveLimiterHint : 0
; COMPUTE_PGM_RSRC2:SCRATCH_EN: 0
; COMPUTE_PGM_RSRC2:USER_SGPR: 2
; COMPUTE_PGM_RSRC2:TRAP_HANDLER: 0
; COMPUTE_PGM_RSRC2:TGID_X_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Y_EN: 1
; COMPUTE_PGM_RSRC2:TGID_Z_EN: 0
; COMPUTE_PGM_RSRC2:TIDIG_COMP_CNT: 1
	.text
	.p2alignl 7, 3214868480
	.fill 96, 4, 3214868480
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.text
	.type	__hip_cuid_c9c457c16614a30b,@object ; @__hip_cuid_c9c457c16614a30b
	.section	.bss,"aw",@nobits
	.globl	__hip_cuid_c9c457c16614a30b
__hip_cuid_c9c457c16614a30b:
	.byte	0                               ; 0x0
	.size	__hip_cuid_c9c457c16614a30b, 1

	.ident	"clang version 21.0.0git (git@github.com:AMD-Lightning-Internal/llvm-project 590b9320a5be90e40268759c6203c01fde121e68)"
	.section	".note.GNU-stack","",@progbits
	.addrsig
	.addrsig_sym __hip_cuid_c9c457c16614a30b
	.amdgpu_metadata
---
amdhsa.kernels:
  - .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .offset:         24
        .size:           4
        .value_kind:     by_value
      - .offset:         32
        .size:           4
        .value_kind:     hidden_block_count_x
      - .offset:         36
        .size:           4
        .value_kind:     hidden_block_count_y
      - .offset:         40
        .size:           4
        .value_kind:     hidden_block_count_z
      - .offset:         44
        .size:           2
        .value_kind:     hidden_group_size_x
      - .offset:         46
        .size:           2
        .value_kind:     hidden_group_size_y
      - .offset:         48
        .size:           2
        .value_kind:     hidden_group_size_z
      - .offset:         50
        .size:           2
        .value_kind:     hidden_remainder_x
      - .offset:         52
        .size:           2
        .value_kind:     hidden_remainder_y
      - .offset:         54
        .size:           2
        .value_kind:     hidden_remainder_z
      - .offset:         72
        .size:           8
        .value_kind:     hidden_global_offset_x
      - .offset:         80
        .size:           8
        .value_kind:     hidden_global_offset_y
      - .offset:         88
        .size:           8
        .value_kind:     hidden_global_offset_z
      - .offset:         96
        .size:           2
        .value_kind:     hidden_grid_dims
    .group_segment_fixed_size: 0
    .kernarg_segment_align: 8
    .kernarg_segment_size: 288
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           _Z12matmul_naivePKfS0_Pfi
    .private_segment_fixed_size: 0
    .sgpr_count:     11
    .sgpr_spill_count: 0
    .symbol:         _Z12matmul_naivePKfS0_Pfi.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     9
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
  - .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         8
        .size:           8
        .value_kind:     global_buffer
      - .address_space:  global
        .offset:         16
        .size:           8
        .value_kind:     global_buffer
      - .offset:         24
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 2048
    .kernarg_segment_align: 8
    .kernarg_segment_size: 28
    .language:       OpenCL C
    .language_version:
      - 2
      - 0
    .max_flat_workgroup_size: 1024
    .name:           _Z12matmul_tiledPKfS0_Pfi
    .private_segment_fixed_size: 0
    .sgpr_count:     14
    .sgpr_spill_count: 0
    .symbol:         _Z12matmul_tiledPKfS0_Pfi.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     26
    .vgpr_spill_count: 0
    .wavefront_size: 32
    .workgroup_processor_mode: 1
amdhsa.target:   amdgcn-amd-amdhsa--gfx1151
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata
