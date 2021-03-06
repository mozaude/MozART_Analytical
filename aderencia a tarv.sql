Select  ad2.nid, 
		case when aderenciacode2<6 then'nao aderiu'			 ---nao aderiu a todas consultas, soma <6
		when aderenciacode2=6 then 'aderiu' end as aderencia ---aderiu a todas consultas, soma =6 (6x1)
		, ad2.AccessFilePath

FROM
(
 SELECT ad1.nid, aderenciacode2=sum(ad1.aderenciacode1), ad1.AccessFilePath
 FROM
 (

 Select *, datediff(dd,t.previousdataproxima,t.datatarv) as daysmissed
		, case when datediff(dd,t.previousdataproxima,t.datatarv)>0 then 0 ---(Nao aderiu) Positivo sao dias apos a marcacao. veio x dias depois
		when datediff(dd,t.previousdataproxima,t.datatarv)<=0 then 1       ---(Aderiu) Negativo ou 0 veio -x dias antes ou no dia da marcacao
	   end as aderenciacode1
from (
SELECT [idtarv], [nid]
      ,datatarv
      ,dataproxima
	  ,LAG( cast([dataproxima] as date), 1, Null) 
	  OVER (PARTITION BY  [nid], [AccessFilePath] 
	  ORDER BY cast([datatarv] as date), cast([dataproxima] as date) ) AS Previousdataproxima
	  ,Nrpick
	  ,[AccessFilePath]
  FROM (
  		SELECT fp.[idtarv], fp.nid,fp.AccessFilePath, fp.[datatarv], fp.[dataproxima], Nrpick
		FROM
			(
				SELECT ROW_NUMBER() OVER (PARTITION BY nid, AccessFilePath ORDER BY cast(datatarv AS DATE) DESC) AS Nrpick, 
				nid, [AccessFilePath], cast(datatarv AS DATE) AS [datatarv], cast(dataproxima AS DATE) as [dataproxima], [idtarv]
				FROM 
				[MozART_q1_2020].[dbo].[t_tarv]
				
			) fp
		WHERE 
		Nrpick>=1 and Nrpick<=7 ----and cast([datatarv] as date) between '2020-04-01' and '2020-10-01' ---and nid='000000000703313372'
	) fp1
 ) t
WHERE Nrpick<7

)ad1
group by ad1.nid, ad1.AccessFilePath
)ad2