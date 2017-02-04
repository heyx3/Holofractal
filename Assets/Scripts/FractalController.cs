using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[RequireComponent(typeof(MeshRenderer))]
public class FractalController : MonoBehaviour
{
	public Transform CamTr;

	public AnimationCurve PowerAnimation;
	public float AnimationDir = 0.0f;
	public float AnimationSpeed = 0.2f;
	public float CurrentT = 0.0f;
	public float FractalRadius = 0.75f;
	
	private MeshRenderer rnd;
	private Transform tr;
	
	
	public void PlayForward()
	{
		AnimationDir = 1.0f;
	}
	public void PlayBackward()
	{
		AnimationDir = -1.0f;
	}
	public void Pause()
	{
		AnimationDir = 0.0f;
	}

	private void Awake()
	{
		rnd = GetComponent<MeshRenderer>();
		tr = transform;
	}
	private void Update()
	{
		CurrentT += Time.deltaTime * AnimationSpeed * AnimationDir;
		if (CurrentT <= 0.0f)
		{
			CurrentT = 0.0f;
			AnimationDir = 0.0f;
		}
		else if (CurrentT >= 1.0)
		{
			CurrentT = 1.0f;
			AnimationDir = 0.0f;
		}
		
		rnd.material.SetFloat("_FractalPower", PowerAnimation.Evaluate(CurrentT));

		Vector3 toCam = (CamTr.position - tr.position).normalized;
		tr.forward = -toCam; //Unity's quad mesh is flipped backwards.
		rnd.material.SetVector("_FractalWorldPos", tr.position - (toCam * FractalRadius));
	}
}
